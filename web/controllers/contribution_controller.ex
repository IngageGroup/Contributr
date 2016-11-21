defmodule Contributr.ContributionController do
require Logger
  use Contributr.Web, :controller

  alias Contributr.Contribution
  alias Contributr.User
  alias Ecto.Changeset

  plug Contributr.Plugs.Authenticated

  def index(conn, %{"organization" => organization}) do
  user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    contributions = Repo.all(Contribution)
    |> Repo.preload(:to_user)
    render(conn, "index.html", contributions: contributions, organization: organization, user: user)
  end

  def new(conn,  %{"organization" => organization}) do
  user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    changeset = Contribution.changeset(%Contribution{})
    eligible_users = eligible_users(conn)
    render(conn, "new.html", changeset: changeset, organization: organization, eligible_users: eligible_users, user: user)
  end

  def create(conn, %{"organization" => organization, "contribution" => contribution_params}) do
  #this whole method sucks.
    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    to_user_id = parse_to_user(contribution_params)
    changeset = Contribution.changeset(%Contribution{from_user_id: user.id, to_user_id: to_user_id}, contribution_params)
    if(deduct_from_user(contribution_params,user)) do
        case Repo.insert(changeset) do
          {:ok, _contribution} ->
            conn
            |> put_flash(:info, "Contribution created successfully.")
            |> redirect(to: contribution_path(conn, :index, organization, user: user))
          {:error, changeset} ->
                  eligible_users = eligible_users(conn)
                  render(conn, "new.html", changeset: changeset, organization: organization, eligible_users: eligible_users, user: user)
        end
    else
       conn
        |> put_flash(:error, "Exceeded allowable amount")
        |> redirect(to: contribution_path(conn, :new, organization))
    end
  end

  def show(conn, %{"organization" => organization, "id" => id}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)
 
    eligible_users = eligible_users(conn)
    render(conn, "show.html", contribution: contribution, organization: organization, eligible_users: eligible_users)
  end

  def edit(conn, %{"organization" => organization, "id" => id}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)

    eligible_users = eligible_users(conn)

    changeset = Contribution.changeset(contribution)
    render(conn, "edit.html", contribution: contribution, organization: organization, eligible_users: eligible_users, changeset: changeset)
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
        eligible_users = eligible_users(conn)
        render(conn, "edit.html", contribution: contribution, organization: organization, eligible_users: eligible_users, changeset: changeset)
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
    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    add_to_user(contribution.amount,user)
  end

  def deduct_from_user(params, user) do
    valid = false
    amount =  parse_to_amount(params)
    current_amount = user.eligible_to_give
    new_amount = current_amount - amount
    if new_amount >= 0 do
        changeset = User.changeset(user,%{"eligible_to_give" => new_amount})
        changeset = Repo.update(changeset)
        valid = true
    end
    valid
  end

  def add_to_user(amount, user) do
      current_amount = user.eligible_to_give
      new_amount = current_amount + amount
      changeset = User.changeset(user,%{"eligible_to_give" => new_amount})
      changeset = Repo.update(changeset)
      valid = true
  end

  def eligible_users(conn) do
    user = current_user(conn)

    Repo.all(  
      from u in Contributr.User,
      where: u.eligible_to_recieve == true and u.id != ^user.id,
      select: {u.name, u.id}
    )
  end

  def current_user(conn) do
   Repo.get_by(Contributr.User , uid: get_session(conn, :current_user).uid)
  end

  def parse_to_user(params) do
    # TODO: See if there is a better way to get this
    String.to_integer(params["to_user"]["id"])
  end
  def parse_to_amount(params) do
     # TODO: See if there is a better way to get this
     String.to_integer(params["amount"])
  end
end



