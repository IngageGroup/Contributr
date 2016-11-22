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

    funds_remaining = Number.Currency.number_to_currency(funds_remaining(user))
    IO.puts("DEBUG___________#{funds_remaining}")
    render(conn, "new.html", changeset: changeset, organization: organization, eligible_users: eligible_users, remaining: funds_remaining)
  end

  def create(conn, %{"organization" => organization, "contribution" => contribution_params}) do
  #This whole method sucks because I couldnt figure out transactions fast enough.
    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    to_user_id = parse_to_user(contribution_params)
    changeset = Contribution.changeset(%Contribution{from_user_id: user.id, to_user_id: to_user_id}, contribution_params)

    change_amount = changeset.get_field(:amount)
    funds_remaining = Number.Currency.number_to_currency(funds_remaining(user))
    case Repo.insert(changeset) do
      {:ok, _contribution} ->
        conn
        |> put_flash(:info, "Contribution created successfully.")
        |> redirect(to: contribution_path(conn, :index, organization, user: user))
      {:error, changeset} ->
          eligible_users = eligible_users(conn)
          render(conn, "new.html", changeset: changeset, organization: organization, eligible_users: eligible_users, remaining: funds_remaining)

    end
  end

  def show(conn, %{"organization" => organization, "id" => id}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)

    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    remaining = Number.Currency.number_to_currency(user.eligible_to_give)
    eligible_users = eligible_users(conn)
    funds_remaining = Number.Currency.number_to_currency(funds_remaining(user))
    render(conn, "show.html", contribution: contribution, organization: organization, eligible_users: eligible_users, remaining: funds_remaining)
  end

  def edit(conn, %{"organization" => organization, "id" => id}) do
    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)
    contribution = Repo.get!(Contribution, id: id["id"])
    |> Repo.preload(:to_user)
    eligible_users = eligible_users(conn)
    changeset = Contribution.changeset(contribution)
    change_amount = changeset.get_field(:amount)
    funds_remaining = Number.Currency.number_to_currency(funds_remaining(user))
    render(conn, "edit.html", contribution: contribution, organization: organization, eligible_users: eligible_users, changeset: changeset, remaining: funds_remaining)
  end

  def update(conn, %{"organization" => organization, "id" => id, "contribution" => contribution_params}) do
    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)

    user = Repo.get_by(Contributr.User, uid: get_session(conn, :current_user).uid)

    to_user_id = parse_to_user(contribution_params)

    changeset = Contribution.changeset(contribution, contribution_params)
    changeset = Ecto.Changeset.change(changeset, %{to_user_id: to_user_id})

    change_amount = changeset.get_field(:amount)
    funds_remaining = Number.Currency.number_to_currency(funds_remaining(user))


    if change_amount <= funds_remaining do
    case Repo.update(changeset) do

      {:ok, contribution} ->
        conn
        |> put_flash(:info, "Contribution updated successfully.")
        |> redirect(to: contribution_path(conn, :show, organization, contribution, remaining: funds_remaining))
      {:error, changeset} ->
        eligible_users = eligible_users(conn)
        render(conn, "edit.html", contribution: contribution, organization: organization, eligible_users: eligible_users, changeset: changeset, remaining: funds_remaining)
    end
    else
        conn
        |> put_flash(:error, "Contribution amount exceeds the allowable amount")
        |> redirect(to: contribution_path(conn, :update, organization, contribution, remaining: funds_remaining))
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

  def funds_remaining(user) do
    ou = Repo.get_by(Contributr.OrganizationsUsers, user_id: user.id)
    o = Repo.get_by(Contributr.Organization, id: ou.org_id)
    id = user.id
    org_id = o.id
    
    mycontributions = Repo.all(from c in Contributr.Contribution,
                              where: c.from_user_id == ^id,
                              select: {c.amount})

    contributions = Enum.reduce(mycontributions, 0, fn(x, acc) -> x + acc end)


    user.eligible_to_give -  contributions
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
end



