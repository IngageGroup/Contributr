defmodule Contributr.ContributionController do
  import Number
  require Number.Macros
  use Contributr.Web, :controller

  alias Contributr.Contribution
  alias Contributr.User
  alias Ecto.Changeset

  plug Contributr.Plugs.Authenticated

  def index(conn, %{"organization" => organization}) do

  user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
  remaining = Number.Currency.number_to_currency(user.eligible_to_give)
    contributions = Repo.all(Contribution)
    |> Repo.preload(:to_user)
    render(conn, "index.html", contributions: contributions, organization: organization, remaining: remaining)
  end

  def new(conn,  %{"organization" => organization}) do

    changeset = Contribution.changeset(%Contribution{})
    eligible_users = eligible_users(conn)
    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    remaining = Number.Currency.number_to_currency(user.eligible_to_give)
    render(conn, "new.html", changeset: changeset, organization: organization, eligible_users: eligible_users, remaining: remaining)
  end

  def create(conn, %{"organization" => organization, "contribution" => contribution_params}) do
  #This whole method sucks because I couldnt figure out transactions fast enough.
    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    remaining = Number.Currency.number_to_currency(user.eligible_to_give)
    to_user_id = parse_to_user(contribution_params)
    changeset = Contribution.changeset(%Contribution{from_user_id: user.id, to_user_id: to_user_id}, contribution_params)
    amount =  parse_to_amount(contribution_params)

    if(deduct_from_user(amount,user)) do
        case Repo.insert(changeset) do
          {:ok, _contribution} ->
            conn
            |> put_flash(:info, "Contribution created successfully.")
            |> redirect(to: contribution_path(conn, :index, organization, user: user))
          {:error, changeset} ->
                  eligible_users = eligible_users(conn)
                  render(conn, "new.html", changeset: changeset, organization: organization, eligible_users: eligible_users, remaining: remaining)
                  add_to_user(amount,user)
        end
    else
       conn
        |> put_flash(:error, "Exceeded allowable amount")
        |> redirect(to: contribution_path(conn, :new, organization, remaining: remaining))
    end
  end

  def show(conn, %{"organization" => organization, "id" => id}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)

    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    remaining = Number.Currency.number_to_currency(user.eligible_to_give)
    eligible_users = eligible_users(conn)
    render(conn, "show.html", contribution: contribution, organization: organization, eligible_users: eligible_users, remaining: remaining)
  end

  def edit(conn, %{"organization" => organization, "id" => id}) do
    contribution = Repo.get!(Contribution, id: id["id"])
    |> Repo.preload(:to_user)
    eligible_users = eligible_users(conn)
    changeset = Contribution.changeset(contribution)
    render(conn, "edit.html", contribution: contribution, organization: organization, eligible_users: eligible_users, changeset: changeset)
  end

  def update(conn, %{"organization" => organization, "id" => id, "contribution" => contribution_params}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)

    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    remaining = Number.Currency.number_to_currency(user.eligible_to_give)

    to_user_id = parse_to_user(contribution_params)
    before_amount = contribution.amount
    after_amount = parse_to_amount(contribution_params)

    if(before_amount > after_amount) do
      change = before_amount - after_amount
      add_to_user(change, user)
    else
      change = after_amount - before_amount
      deduct_from_user(change, user)
    end

    
    changeset = Contribution.changeset(contribution, contribution_params)
    changeset = Ecto.Changeset.change(changeset, %{to_user_id: to_user_id})


    case Repo.update(changeset) do
      {:ok, contribution} ->
        conn
        |> put_flash(:info, "Contribution updated successfully.")
        |> redirect(to: contribution_path(conn, :show, organization, contribution, remaining: remaining))
      {:error, changeset} ->
        eligible_users = eligible_users(conn)
        render(conn, "edit.html", contribution: contribution, organization: organization, eligible_users: eligible_users, changeset: changeset, remaining: remaining)
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

  def deduct_from_user(amount, user) do
    valid = false
    if amount do
        current_amount = user.eligible_to_give
        new_amount = current_amount - amount
        if new_amount >= 0 do
            changeset = User.changeset(user,%{"eligible_to_give" => new_amount})
            changeset = Repo.update(changeset)
            valid = true
        end
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
     unless Number.Macros.is_blank params["amount"] do
        String.to_float(params["amount"])
     end
  end
end



