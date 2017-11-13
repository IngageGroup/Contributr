defmodule Contributr.EventUsersController do
  import Number
  require Number.Macros
  require Logger
  use Contributr.Web, :controller
  alias Contributr.EventUsers
  alias Contributr.Event
  alias Contributr.Organization
  alias Contributr.Contribution
  alias Contributr.User

  plug Contributr.Plugs.Authenticated


  #  def index(conn, %{"organization" => organization, "event_id" => event_id}) do
  #
  #    event_users = load_users_by_event(event_id)
  #    render(conn, "index.html", organization: organization, event_id: event_id, event_users: event_users)
  #  end


  def list(conn, %{"organization" => organization, "event_id" => event_id}) do
    event = Repo.get(Event, event_id)
    event_users = load_users_by_event(event_id)
    render(conn, "show_event.html", organization: organization, event: event, event_users: event_users)
  end

  def new_event_user(conn, %{"organization" => organization, "event_id" => event_id}) do
    event = Repo.get(Event, event_id)
    changeset = EventUsers.changeset(%EventUsers{eligible_to_give: event.default_bonus})
    org_users = all_unassigned_users(organization,event_id)
    render(conn, "new.html",
      organization: organization,
      event: event,
      users: org_users,
      changeset: changeset)
  end

  def edit_event_user(conn, _params) do
    current_user = get_session(conn, :current_user)
    user_id = _params["id"]
    Logger.info(user_id)
    event_id = _params["event_id"]
    Logger.info(event_id)
    event_user = Repo.get!(EventUsers, user_id) |> Repo.preload([:event])|> Repo.preload([:user])
    user = event_user.user
    changeset = EventUsers.changeset(event_user)
    users = selected_user(event_user)

    render(conn, "edit.html",
      organization_id: current_user.org_id,
      event_id: event_id,
      users: users,
      changeset: changeset)
  end


  def create_event_user(conn, %{"organization" => organization, "event_id" => event_id, "event_users" => event_users_params}) do
    #create event
    changeset = EventUsers.changeset(%EventUsers{event_id: event_id}, event_users_params)

    case Repo.insert(changeset) do
      {:ok, _event_users} ->
        conn
        |> put_flash(:info, "Event users created successfully.")
        |> redirect(to: event_users_path(conn, :index,  event_id: event_users_params.event_id))
      {:error, changeset} ->
        render(conn, "new.html", event_id: event_users_params.event_id, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event_users = Repo.get!(EventUsers, id)
    render(conn, "show.html", event_id: id, event_users: event_users)
  end

  def update(conn, _params) do

    current_user = get_session(conn, :current_user)
    event_id = _params["id"]
    event_user = _params["event_users"]
    event_user_user = event_user["user"]
    event_user_id = String.to_integer(event_user_user["id"])
    IO.inspect(event_user_id)
    updated_etg = elem(Float.parse(event_user["eligible_to_give"]), 0)
    updated_etr = event_user["eligible_to_receive"]

    changes_params = %{eligible_to_receive: updated_etr,eligible_to_give: updated_etg}


    event_users = Repo.get!(EventUsers, event_user_id)
    changeset = EventUsers.changeset(event_users, changes_params)
    case Repo.update(changeset) do
      {:ok, event_users} ->
        conn
        |> put_flash(:info, "Event users updated successfully.")
        |> redirect(to:  event_users_path(conn, :list,current_user.org_name, event_id))
      {:error, changeset} ->
        render(conn, "edit.html", event_users: event_users, changeset: changeset)
    end
  end

  def delete_event_user(conn, _params) do
    IO.inspect(_params)
    current_user = get_session(conn, :current_user)
    event_user_id = String.to_integer(_params["id"])
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
      order_by: [desc: eu.id],
      select: %{
        event_user: eu,
        event_user_id: eu.id,
        event_name: e.name,
        user_name: u.name,
        user_id: u.id,
        eligible_to_receive: eu.eligible_to_receive,
        eligible_to_give: eu.eligible_to_give
      }
    )
  end

  def all_unassigned_users(org_name, event_id) do
    Repo.all(
      from ou in Contributr.OrganizationsUsers,
      join: eu in Contributr.EventUsers,
      join: u in assoc(ou, :user),
      where: ou.user_id != eu.user_id,
      select: {u.name, eu.id}
    )
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

end
