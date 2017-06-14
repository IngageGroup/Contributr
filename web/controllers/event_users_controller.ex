defmodule Contributr.EventUsersController do
  use Contributr.Web, :controller

  alias Contributr.EventUsers

  def index(conn, _params) do  
   
    event_users = Repo.all(from eu in EventUsers,
                           join: u in assoc(eu, :user),
                           join: e in assoc(eu, :event),
                           preload: [user: u],
                           preload: [event: e]
                           )
                      


    render(conn, "index.html", event_users: event_users)
  end

  def new(conn, _params) do
    changeset = EventUsers.changeset(%EventUsers{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event_users" => event_users_params}) do
    changeset = EventUsers.changeset(%EventUsers{}, event_users_params)

    case Repo.insert(changeset) do
      {:ok, _event_users} ->
        conn
        |> put_flash(:info, "Event users created successfully.")
        |> redirect(to: event_users_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event_users = Repo.get!(EventUsers, id)
    render(conn, "show.html", event_users: event_users)
  end

  def edit(conn, %{"id" => id}) do
    event_users = Repo.get!(EventUsers, id)
    changeset = EventUsers.changeset(event_users)
    render(conn, "edit.html", event_users: event_users, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event_users" => event_users_params}) do
    event_users = Repo.get!(EventUsers, id)
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
    |> redirect(to: event_users_path(conn, :index))
  end

  
  def org_events() do    
    Repo.all(  
      from e in Contributr.Event,
      where: e.org_id == 2,
      select: {e.name, e.event_id}
    )
  end



end
