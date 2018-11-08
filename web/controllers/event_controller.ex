defmodule Contributr.EventController do
  import Number
  require Number.Macros
  use Contributr.Web, :controller

  alias Contributr.Event
  alias Contributr.EventUsers
  alias Contributr.User
  alias Contributr.Organization
  alias Contributr.EventUsers

  plug Contributr.Plugs.Authenticated
  plug Contributr.Plugs.CheckPermission
  plug Contributr.Plugs.OrganizationMember

  def index(conn, %{"organization" => organization}) do
    org = Repo.get_by!(Organization, name: organization)
    events = org_events(org)
    render(conn, "index.html", events: events, organization: organization)
  end

  def show(conn, %{"organization" => organization, "id" => id}) do
    event = Repo.get!(Event, id)
    render(conn, "show.html", event: event, organization: organization)
  end

  def new(conn, %{"organization" => organization}) do
    changeset = Event.changeset(%Event{})
    render(conn, "new.html", organization: organization, changeset: changeset)
  end

  def create(conn, %{"organization" => organization, "event" => event_params}) do
    org = Repo.get_by!(Organization, name: organization)

    #create event
    changeset = Event.changeset(%Event{org_id: org.id}, event_params)

    case Repo.insert(changeset) do
      {:ok, _event} ->
        default_event_users(organization,_event)
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: event_path(conn, :index, organization))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, organization: organization)
    end
  end

  def default_event_users(org_name, event) do
    query = org_user_query org_name
    event_id =  Map.get(event, :id)
    event_bonus = Map.get(event, :default_bonus)
    inserted_at = Map.get(event, :inserted_at)
    params = %{event_id: event_id,  eligible_to_give: event_bonus,  eligible_to_receive: true, inserted_at: inserted_at, updated_at: inserted_at}
    user_ids = Repo.all(query)
    users = Enum.map(user_ids, fn(u) -> Enum.concat(u, params) end)
    Repo.insert_all(EventUsers,users)
  end

  def org_user_query(org_name) do
    from u in Contributr.User,
         join: ou in assoc(u, :organizations_users),
         join: o in assoc(ou, :org),
         where: o.name == ^org_name,
         select: %{user_id: u.id}
  end

  def dashboard(conn, %{"organization" => organization, "id" => id}) do
    event = Repo.get!(Event, id)
    changeset = Event.changeset(event)
    event_users = load_users_by_event(id)
    event_users_changeset = EventUsers.changeset(event_users)

    render(conn, "dashboard.html",
      event: event,
      event_changeset: changeset,
      event_users_changeset: event_users_changeset,
      organization: organization)
  end

  def edit(conn, %{"organization" => organization, "id" => id}) do
    event = Repo.get!(Event, id)
    changeset = Event.changeset(event)


    render(conn, "edit.html", event: event, changeset: changeset, organization: organization)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    current_user = get_session(conn, :current_user)
    event = Repo.get!(Event, id)|> Repo.preload([:event_users])|> Repo.preload([:org])
    default_bonus = elem(Float.parse(event_params["default_bonus"]),0)
    desc = event_params["description"]
    name = event_params["name"]
    end_date = elem(Ecto.Date.cast(event_params["end_date"]),1)
    s_date = elem(Ecto.Date.cast(event_params["start_date"]),1)

    update = %{default_bonus: default_bonus, description: desc, name: name, end_date: end_date,start_date: s_date}
    changeset = Event.changeset(event, update)


    case Repo.update(changeset) do
      {:ok, _event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: "/")
      {:error, changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset, current_user: get_session(conn, :current_user))
    end
  end

  def load_users_by_event(event_id) do
    Repo.all(
      from eu in EventUsers,
      join: u in assoc(eu, :user),
      join: e in assoc(eu, :event),
      where: eu.event_id == ^event_id,
      select: eu
    )
  end

  def org_events(org) do
    Repo.all(
      from e in Contributr.Event,
      join: o in assoc(e, :org),
      join: eu in assoc(e, :event_users),
      where: o.id == ^org.id,
      select: e,
      preload: [org: o],
      preload: [event_users: eu])
  end

  def contributions_to_user_query(user_id, event_id) do
    from eu in Contributr.EventUsers,
         join: c in Contributr.Contribution,
         where: c.to_user_id == ^user_id,
         where: eu.event_id == ^event_id,
         select: c
  end
end