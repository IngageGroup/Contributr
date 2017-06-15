defmodule Contributr.EventUsersController do
  import Number
  require Number.Macros
  use Contributr.Web, :controller

  alias Contributr.Event
  alias Contributr.EventUsers

  plug Contributr.Plugs.Authenticated


  def index(conn, %{"event_id" => event_id}) do
    event_users = load_users_by_event(event_id)
    render(conn, "index.html", event_users: event_users)
  end

  def load_users_by_event(event_id) do
    Repo.all(from eu in EventUsers,
        join: u in assoc(eu, :user),
        join: e in assoc(eu, :event),
        where: e.id == ^event_id,
        preload: [user: u],
        preload: [event: e]
    )
  end

  def load_all_users do
    Repo.all(from eu in EventUsers,
       join: u in assoc(eu, :user),
       join: e in assoc(eu, :event),
       preload: [user: u],
       preload: [event: e]
    )
  end
  
  def new(conn, _params) do
    # TODO: It doesn't look like this knows event_id to assign to correct event
    changeset = EventUsers.changeset(%EventUsers{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event_users" => event_users_params}) do
    changeset = EventUsers.changeset(%EventUsers{}, event_users_params)

    case Repo.insert(changeset) do
      {:ok, _event_users} ->
        conn
        |> put_flash(:info, "Event users created successfully.")
        |> redirect(to: event_users_path(conn, :index, event_id: event_users_params.event_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event_users = Repo.get!(EventUsers, id)
    render(conn, "show.html", event_users: event_users)
  end

  def edit(conn, %{"id" => id}) do

    event_users = Repo.get!(EventUsers, id) |> Repo.preload([:event])|> Repo.preload([:user])
    changeset = EventUsers.changeset(event_users)
    render(conn, "edit.html", event_users: event_users, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event_users" => event_users_params}) do
    event_users = Repo.get!(EventUsers, id) |> Repo.preload([:event])|> Repo.preload([:user])
    changeset = EventUsers.changeset(event_users, event_users_params)

    case Repo.update(changeset) do
      {:ok, event_users} ->
        conn
        |> put_flash(:info, "Event users updated successfully.")
        |> redirect(to: event_users_path(conn, :show, event_users))
      {:error, changeset} ->
        render(conn, "edit.html", event_users: event_users, changeset: changeset) 
    end
  end

  def delete(conn, %{"id" => id}) do
    event_users = Repo.get!(EventUsers, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(event_users)

    conn
    |> put_flash(:info, "Event users deleted successfully.")
    |> redirect(to: event_users_path(conn, :index, event_id: event_users.event_id))
  end

end
