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

  def index(conn, %{"organization" => organization}) do
    org = org = Repo.get_by!(Organization, name: organization)
    events = org_events(organization)
    render(conn, "index.html", events: events, organization: org)
  end

  def org_events(orgname) do
    Repo.all(
      from e in Contributr.Event,
      join: o in assoc(e, :org),
      where: o.name == ^orgname,
      select: e
    )
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
    IO.inspect("INSPECT!!!!!!!!!")
    IO.inspect(users)
    Repo.insert_all(EventUsers,users)
  end

  def org_user_query(org_name) do
    from u in Contributr.User,
         join: ou in assoc(u, :organizations_users),
         join: o in assoc(ou, :org),
         where: o.name == ^org_name,
         select: %{user_id: u.id}
  end

  def edit(conn, %{"organization" => organization, "id" => id}) do
    event = Repo.get!(Event, id)
    changeset = Event.changeset(event)

    render(conn, "edit.html", event: event, changeset: changeset, organization: organization)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Repo.get!(Event, id) |> Repo.preload([:org])
    changeset = Event.changeset(event, event_params)

    case Repo.update(changeset) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: event_path(conn, :index, event.org.url))
      {:error, changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset, current_user: get_session(conn, :current_user))
    end
  end
end