defmodule Contributr.EventUsersController do
  import Number
  require Number.Macros
  require Logger
  use Contributr.Web, :controller
  alias Contributr.EventUsers
  alias Contributr.Event
  alias Contributr.Contribution
  alias Contributr.Role

  plug Contributr.Plugs.Authenticated

  def list(conn, %{"organization" => organization, "event_id" => event_id}) do
    event = Repo.get(Event, event_id)
    user_info = Enum.map(load_users_by_event(event_id), fn (eu) ->
      Enum.into(comments_for(eu.event_user_id),
        Enum.into(total_received(eu.event_user_id),
          Enum.into(total_allocated(eu.event_user_id),
            eu)))end)
    encoded_ui = Poison.encode(user_info)
    case role do
      %Role{name: "Admin"} = r ->
        render(conn, "show_event.html", organization: organization, event: event, event_users: user_info, encoded: encoded_ui)
      _   ->
        conn
        |> put_flash(:error, "You do not have permission to see this page")
        |> redirect(to: "/")
    end
  end

  def list_comments(conn, params) do
    current_user = get_session(conn, :current_user)
    organization = current_user.org_name
    eu_id = params["id"]
    event_id = params["event_id"]
    comments = comments_for(eu_id)
    event_user = Repo.get(EventUsers, String.to_integer(eu_id))|> Repo.preload([:user])
    render(conn, "show_comments.html", organization: organization, event: event_id,event_user: event_user, comments: comments)
  end

  def new_event_user(conn, %{"organization" => organization, "event_id" => event_id}) do
    current_user = get_session(conn,:current_user)
    event = Repo.get(Event, event_id)
    changeset = EventUsers.changeset(%EventUsers{eligible_to_give: event.default_bonus})
    org_users = all_unassigned_users(current_user,event_id)
    render(conn, "new.html",
      organization: organization,
      event: event,
      users: org_users,
      changeset: changeset)
  end


  def create_event_user(conn, %{"organization" => organization, "event_id" => event_id, "event_users" => event_users_params}) do
    #create event
    current_user = get_session(conn, :current_user)

    user_id = String.to_integer(event_users_params["user"]["id"])
    id = String.to_integer(event_id)
    eligible_to_give = elem(Float.parse(event_users_params["eligible_to_give"]), 0)
    eligible_to_receive =  if (event_users_params["eligible_to_receive"] == "true") do true else false end

    changeset = EventUsers.changeset(%EventUsers{event_id: id,
      user_id: user_id,
      eligible_to_give: eligible_to_give,
      eligible_to_receive: eligible_to_receive }
    )

    case Repo.insert(changeset) do
      {:ok, _event_users} ->
        conn
        |> put_flash(:info, "Event users created successfully.")
        |> redirect(to: event_users_path(conn, :list, current_user.org_name, id))
      {:error, changeset} ->
        org_users = all_unassigned_users(get_session(conn, :current_user),event_id)
        render(conn, "new.html",
          organization: organization,
          event: Repo.get(Event, event_id),
          users: org_users,
          changeset: changeset)
    end
  end

  def edit_event_user(conn, params) do
    current_user = get_session(conn, :current_user)
    user_id = params["id"]
    Logger.info(user_id)
    event_id = params["event_id"]
    Logger.info(event_id)
    event_user = Repo.get!(EventUsers, user_id) |> Repo.preload([:event])|> Repo.preload([:user])
    changeset = EventUsers.changeset(event_user)
    users = selected_user(event_user)

    render(conn, "edit.html",
      organization_id: current_user.org_id,
      event_id: event_id,
      users: users,
      changeset: changeset)
  end




  def show(conn, %{"id" => id}) do
    event_users = Repo.get!(EventUsers, id)
    render(conn, "show.html", event_id: id, event_users: event_users)
  end

  def update(conn, params) do

    current_user = get_session(conn, :current_user)
    event_id = params["id"]
    event_user = params["event_users"]
    event_user_user = event_user["user"]
    event_user_id = String.to_integer(event_user_user["id"])
    updated_etg = elem(Float.parse(event_user["eligible_to_give"]), 0)
    updated_etr = event_user["eligible_to_receive"]

    changes_params = %{eligible_to_receive: updated_etr,eligible_to_give: updated_etg}


    event_users = Repo.get!(EventUsers, event_user_id)
    changeset = EventUsers.changeset(event_users, changes_params)
    case Repo.update(changeset) do
      {:ok, _event_users} ->
        conn
        |> put_flash(:info, "Event users updated successfully.")
        |> redirect(to:  event_users_path(conn, :list,current_user.org_name, event_id))
      {:error, changeset} ->
        render(conn, "edit.html", event_users: event_users, changeset: changeset)
    end
  end

  def delete_event_user(conn, params) do
    current_user = get_session(conn, :current_user)
    event_user_id = String.to_integer(params["id"])
    event_users = Repo.get!(EventUsers, event_user_id) |> Repo.preload([:event])|> Repo.preload([:user])
    user = event_users.user
    event = event_users.event

    Repo.delete_all(from c in Contribution,
                    where: c.to_user_id == ^user.id or c.from_user_id == ^user.id and c.event_id == ^event.id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(event_users)

    conn
    |> put_flash(:info, "Users deleted.")
    |> redirect(to: event_users_path(conn, :list, current_user.org_name, event.id))
  end

  def load_users_by_event(event_id) do
    Repo.all(
      from eu in EventUsers,
      join: u in assoc(eu, :user),
      join: e in assoc(eu, :event),
      where: eu.event_id == ^event_id,
      select: %{
        event_user_id: eu.id,
        event_name: e.name,
        user_name: u.name,
        user_id: u.id,
        eligible_to_give: eu.eligible_to_give,
        eligible_to_receive: eu.eligible_to_receive
      }
    )
  end

  def all_unassigned_users(current_user, event_id) do
      all_users = Repo.all(from(ou in Contributr.OrganizationsUsers,
        where: ou.org_id == ^current_user.org_id,
        join: u in assoc(ou, :user),
        select: {u.name, u.id}))
      event_users = Repo.all(from(eu in EventUsers,
        where: eu.event_id == ^event_id,
        join: u in assoc(eu, :user),
        select: {u.name, u.id}))
      Enum.reject(all_users, fn (user) -> Enum.any?(event_users, fn (eu) -> user == eu end)  end)
  end

  def selected_user(user) do
    Repo.all(
      from eu in Contributr.EventUsers,
      join: u in assoc(eu, :user),
      where: eu.id == ^user.id,
      select: {u.name, eu.id }
    )
  end

  def load_all_users() do
    Repo.all(from eu in EventUsers,
             join: u in assoc(eu, :user),
             join: e in assoc(eu, :event),
             preload: [user: u],
             preload: [event: e]
    )
  end

  defp total_allocated(event_user_id) do
    case Repo.one(from eu in EventUsers,
                  join: u in assoc(eu, :user),
                  join: e in assoc(eu, :event),
                  join: c in Contribution,
                  where: eu.id == ^event_user_id,
                  where: c.from_user_id == u.id and c.event_id == e.id,
                  select: sum(c.amount)) do
              nil ->
                %{total_allocated: 0}
              result ->
                %{total_allocated: Number.Conversion.to_float(result)}
    end
  end

  defp comments_for(event_user_id) do
    case Repo.all(from eu in EventUsers,
                  join: u in assoc(eu, :user),
                  join: e in assoc(eu, :event),
                  join: c in Contribution,
                  where: eu.id == ^event_user_id,
                  where: c.to_user_id == u.id and c.event_id == e.id,
                  select: c.comments) do

      [nil]->
        %{comments: []}
      result ->
        %{comments: result}
    end

  end

  defp total_received(event_user_id) do
    case Repo.one(from eu in EventUsers,
                  join: u in assoc(eu, :user),
                  join: e in assoc(eu, :event),
                  join: c in Contribution,
                  where: eu.id == ^event_user_id,
                  where: c.to_user_id == u.id and c.event_id == e.id,
                  select: sum(c.amount)) do
      [nil]->
       %{total_received: 0}
      result ->
        %{total_received: Number.Currency.number_to_currency(result)}
    end
  end
end
