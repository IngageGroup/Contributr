defmodule Contributr.ContributionController do
require Logger
  use Contributr.Web, :controller

  alias Contributr.Contribution
  plug Contributr.Plugs.Authenticated


 
  def index(conn, _params) do
    contributions = Repo.all(Contribution)
    render(conn, "index.html", contributions: contributions)
  end

  def new(conn, _params) do
    changeset = Contribution.changeset(%Contribution{})    
    render(conn, "new.html", changeset: changeset, current_user: current_user(conn), all_users: [])
  end

  def create(conn, %{"organization" => organization, "contribution" => contribution_params}) do    
    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    changeset = Contribution.changeset(%Contribution{from_user_id: user.id}, contribution_params)
    
    case Repo.insert(changeset) do
      {:ok, _contribution} ->
        conn
        |> put_flash(:info, "Contribution created successfully.")
        |> redirect(to: contribution_path(conn, :index, organization))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    contribution = Repo.get!(Contribution, id)
    render(conn, "show.html", contribution: contribution)
  end

  def edit(conn, %{"id" => id}) do


    contribution = Repo.get!(Contribution, id)
    changeset = Contribution.changeset(contribution)
    render(conn, "edit.html", contribution: contribution, changeset: changeset)
  end

  def update(conn, %{"organization" => organization, "id" => id, "contribution" => contribution_params}) do
    contribution = Repo.get!(Contribution, id)
    changeset = Contribution.changeset(contribution, contribution_params)

    case Repo.update(changeset) do
      {:ok, contribution} ->
        conn
        |> put_flash(:info, "Contribution updated successfully.")
        |> redirect(to: contribution_path(conn, :show, organization, contribution))
      {:error, changeset} ->
        render(conn, "edit.html", contribution: contribution, changeset: changeset)
    end
  end

  def delete(conn, %{"organization" => organization, "id" => id}) do
    contribution = Repo.get!(Contribution, id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(contribution)
    conn
    |> put_flash(:info, "Contribution deleted successfully.")
    |> redirect(to: contribution_path(conn, :index, organization))
    end




  def current_user(conn) do
   Repo.get_by(Contributr.User , uid: get_session(conn, :current_user).uid)
  end
  end



