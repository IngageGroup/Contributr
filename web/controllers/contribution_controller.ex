defmodule Contributr.ContributionController do
  import Number
  require Number.Macros
  use Contributr.Web, :controller

  alias Contributr.Contribution
  alias Contributr.EventUsers

  plug Contributr.Plugs.Authenticated



  def index(conn, %{"organization" => organization, "event_id" => event_id}) do
    user = get_session(conn, :current_user)
    funds_remaining = funds_remaining(user, event_id)


    contributions = Repo.all(from c in Contributr.Contribution,
                          where: c.from_user_id == ^user.user_id and c.event_id == ^event_id ,
                          select: c)
    |> Repo.preload(:to_user)


    render(conn,
    "index.html",
    contributions: contributions,
    organization: organization,
    event_id: event_id,
    remaining: funds_remaining )
  end

  def new(conn,  %{"organization" => organization, "event_id" => event_id}) do
    eligible_users = eligible_users(conn, event_id)
    user = get_session(conn, :current_user)
    funds_remaining = funds_remaining(user, event_id)
    changeset = Contribution.changeset(%Contribution{event_id: event_id})
    Ecto.Changeset.validate_number(changeset,:amount, less_than_or_equal_to: funds_remaining)

    render(conn,
        "new.html",
         changeset: changeset,
         organization: organization,
         eligible_users: eligible_users,
         event_id: event_id,
         remaining: funds_remaining)
  end

  def create(conn, %{"organization" => organization, "event_id" => event_id, "contribution" => contribution_params}) do
    user = get_session(conn, :current_user)
    to_user_id = parse_to_user(contribution_params)

    changeset = Contribution.changeset(%Contribution{from_user_id: user.user_id,
      to_user_id: to_user_id,
      event_id: String.to_integer(event_id)},
      contribution_params)


    funds_remaining = funds_remaining(user, event_id)

    entered_amount = Number.Conversion.to_float(contribution_params["amount"])

    if entered_amount <= funds_remaining do
        case Repo.insert(changeset) do
          {:ok, _contribution} ->
            conn
            |> redirect(to: contribution_path(conn, :index, organization, event_id))
          {:error, changeset} ->
              eligible_users = eligible_users(conn, event_id)
              render(conn, "new.html",
                            changeset: changeset,
                            organization: organization,
                            eligible_users: eligible_users,
                            event_id: event_id,
                            remaining: funds_remaining)
        end
    else
        msg = "Entry exceeds allowable amount"
        eligible_users = eligible_users(conn, event_id)
        conn
        |> put_flash(:error, msg)
        |> redirect(to: contribution_path(conn, :new, organization, event_id))

    end
  end


  def update(conn, %{"organization" => organization, "id" => id, "event_id" => event_id, "contribution" => contribution_params}) do

    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)



    user =  get_session(conn, :current_user)
    contributionToUpdate = Repo.get(Contribution, id)

    #TODO handle this with guardian, for now this will work.
    check_ownership(conn, contributionToUpdate)

    to_user_id = parse_to_user(contribution_params)

    changeset = Contribution.changeset(contribution, contribution_params)
    changeset = Ecto.Changeset.change(changeset, %{to_user_id: to_user_id})

    funds_remaining = funds_remaining(user, event_id)
    adj_funds_remaining = funds_remaining + contribution.amount #The form should accept the current amount plus what the user has left.
    entered_amount = Number.Conversion.to_float(contribution_params["amount"])

    if entered_amount <= adj_funds_remaining do
        case Repo.update(changeset) do
          {:ok, contribution} ->
            conn
            |> put_flash(:info, "Contribution updated successfully.")
            |> redirect(to: contribution_path(conn, :show, organization, event_id, contribution, remaining: "#{funds_remaining}"))
          {:error, changeset} ->
            eligible_users = eligible_users(conn, event_id)
            render(conn,
                    "edit.html",
                    contribution: contribution,
                    organization: organization,
                    event_id: event_id,
                    eligible_users: eligible_users,
                    changeset: changeset,
                    remaining: funds_remaining)
        end
    else
        formatted_entry = Number.Currency.number_to_currency(entered_amount)
        msg = "#{formatted_entry} exceeds allowable amount."

        eligible_users = eligible_users(conn, event_id)
        conn
        |> put_flash(:error, msg)
        |> redirect(to: contribution_path(conn, :edit, organization, contribution, event_id: event_id))
    end
  end

  def show(conn, %{"organization" => organization, "event_id" => event_id, "id" => id}) do


    contribution = Repo.get!(Contribution, id)
    |> Repo.preload(:to_user)

    #TODO handle this with guardian, for now this will work.
    check_ownership(conn, contribution)


    current_user = get_session(conn, :current_user)
    eligible_users = eligible_users(conn, event_id)
    funds_remaining = funds_remaining(current_user, event_id)


    render(conn,
            "show.html",
            contribution: contribution,
            organization: organization,
            eligible_users: eligible_users,
            event_id: event_id,
            remaining: funds_remaining)
  end


  def edit(conn, %{"organization" => organization, "event_id" => event_id, "id" => id}) do
    user =  get_session(conn, :current_user)

    contribution = Repo.get(Contribution, id)
    |> Repo.preload(:to_user)

    #TODO handle this with guardian, for now this will work.
    check_ownership(conn, contribution)

    eligible_users = eligible_users(conn, event_id)

    funds_remaining = funds_remaining(user, event_id)
    changeset = Contribution.changeset(contribution)

    Ecto.Changeset.validate_number(changeset,:amount, less_than_or_equal_to: funds_remaining)
    render(conn,
            "edit.html",
            contribution: contribution,
            organization: organization,
            eligible_users: eligible_users,
            changeset: changeset,
            event_id: event_id,
            remaining: funds_remaining)
  end

  def delete(conn, %{"organization" => organization, "id" => id, "event_id" => event_id}) do

    contribution = Repo.get!(Contribution, id)
    #TODO handle this with guardian, for now this will work.
    check_ownership(conn, contribution)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(contribution)
    conn
    |> put_flash(:info, "Contribution deleted successfully.")
    |> redirect(to: contribution_path(conn, :index, organization, event_id))
  end


  def funds_remaining(current_user, event_id) do
    eu = Repo.get_by(Contributr.EventUsers, user_id: current_user.user_id, event_id: String.to_integer(event_id))
    mycontributions = round(total_allocated(eu.id))
    remaining = eu.eligible_to_give - mycontributions
  end


  defp total_allocated(event_user_id) do
    case Repo.one(from eu in EventUsers,
                  join: u in assoc(eu, :user),
                  join: e in assoc(eu, :event),
                  join: c in Contribution,
                  where: eu.id == ^event_user_id,
                  where: c.from_user_id == u.id and c.event_id == e.id,
                  select: sum(c.amount)) do
      nil ->
         0
      result ->
          Number.Conversion.to_float(result)
    end
  end

  def eligible_users(conn, event_id) do
    user = get_session(conn, :current_user)
    Repo.all(
      from eu in Contributr.EventUsers,
      join: u in assoc(eu, :user),
      where: eu.eligible_to_receive == true  and eu.event_id == ^event_id and eu.user_id != ^user.user_id,
      order_by: u.name,
      select: {u.name, u.id}
    )
  end


  def parse_to_user(params) do
    String.to_integer(params["to_user"]["id"])
  end

  def check_ownership(conn, contribution) do
    user = get_session(conn, :current_user)
    if  user.user_id != contribution.from_user_id do
        msg = "You must own the contribution in order to edit or view it"
        conn
        |> put_flash(:error, msg)
        |> redirect(to: "/")
    end
  end
end
