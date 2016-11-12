defmodule Contributr.ContributionController do
require Logger
  use Contributr.Web, :controller

  alias Contributr.Contribution
  alias Contributr.User
  alias Ecto.Changeset

  plug Contributr.Plugs.Authenticated

  def index(conn, %{"organization" => organization}) do
    contributions = Repo.all(Contribution)
    |> Repo.preload(:to_user)
    render(conn, "index.html", contributions: contributions, organization: organization)
  end

  def new(conn,  %{"organization" => organization}) do
    changeset = Contribution.changeset(%Contribution{})
    eligible = Repo.all(  
      from u in Contributr.User,
      #where: u.eligible_to_recieve == true,
      select: {u.name, u.id}    
    )
    render(conn, "new.html", changeset: changeset, organization: organization, eligible_users: eligible)
  end

  def create(conn, %{"organization" => organization, "contribution" => contribution_params}) do
    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    to_user_id = parse_to_user(contribution_params)
    changeset = Contribution.changeset(%Contribution{from_user_id: user.id, to_user_id: to_user_id}, contribution_params)
    
    case Repo.insert(changeset) do
      {:ok, _contribution} ->
        conn
        |> put_flash(:info, "Contribution created successfully.")
        |> redirect(to: contribution_path(conn, :index, organization))
      {:error, changeset} ->
        eligible = Repo.all(  
         from u in Contributr.User,
         #where: u.eligible_to_recieve == true,
         select: {u.name, u.id}
        )

        render(conn, "new.html", changeset: changeset, organization: organization, eligible_users: eligible)
    end
  end

  def show(conn, %{"organization" => organization, "id" => id}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)
 
    eligible = eligible_users(conn)
    render(conn, "show.html", contribution: contribution, organization: organization, eligible_users: eligible)
  end

  def edit(conn, %{"organization" => organization, "id" => id}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)

    eligible = Repo.all(
      from u in Contributr.User,
      where: u.eligible_to_recieve == true,
      select: {u.name, u.id}
    )

    #eligible = Repo.all(User)  
    #|> Enum.map(&{&1.name, &1.id})

    #  from u in Contributr.User,
      #where: u.eligible_to_recieve == true,
    #  select: u
    #)

    #eligible2 = eligible |> Enum.Map(fn {k, v} -> Logger.info "#{k} = #{v}" end)
    Logger.info "THIS IS ELIGIBLE #{inspect eligible}"

    #Logger.info "THIS IS USERS #{inspect eligible.length}"

    #eligible = eligible_users(conn)
    #Logger.info "#{eligible.length}"

    changeset = Contribution.changeset(contribution)
    render(conn, "edit.html", contribution: contribution, organization: organization, eligible_users: eligible, changeset: changeset)
  end

  def update(conn, %{"organization" => organization, "id" => id, "contribution" => contribution_params}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)

    to_user_id = parse_to_user(contribution_params)
    
    changeset = Contribution.changeset(contribution, contribution_params)
    changeset = Ecto.Changeset.change(changeset, %{to_user_id: to_user_id})

    case Repo.update(changeset) do
      {:ok, contribution} ->
        conn
        |> put_flash(:info, "Contribution updated successfully.")
        |> redirect(to: contribution_path(conn, :show, organization, contribution))
      {:error, changeset} ->
        eligible = eligible_users(conn)
        render(conn, "edit.html", contribution: contribution, organization: organization, eligible_users: eligible, changeset: changeset)
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


  def eligible_users(conn) do
    user = current_user(conn)

    Repo.all(  
      from u in Contributr.User,
      where: u.eligible_to_recieve == true and u.from_user_id != ^user.id,
      select: u
    )

    #
  end

  def current_user(conn) do
   Repo.get_by(Contributr.User , uid: get_session(conn, :current_user).uid)
  end

  def parse_to_user(params) do
    # TODO: See if there is a better way to get this
    String.to_integer(params["to_user"]["id"])
  end
end



