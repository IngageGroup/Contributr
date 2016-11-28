defmodule Contributr.Contribution do
  use Contributr.Web, :model

  schema "contributions" do
    belongs_to :to_user, Contributr.User
    belongs_to :from_user, Contributr.User
    field :amount, :float
    field :comments, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:to_user_id, :from_user_id, :amount, :comments])
    |> validate_required([:to_user_id, :from_user_id, :amount, :comments])
    |> validate_length(:comments, min: 20, max: 255)
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end

  @spec funds_received(Ecto.Query.t, String.t) :: [Ecto.Query.t]
  def funds_received(query,id) do
     from c in query,
     where: c.to_user_id == ^id,
     select: sum(c.amount)
  end

  @spec funds_spent(Ecto.Query.t, String.t) :: [Ecto.Query.t]
  def funds_spent(query,id) do
     from c in query,
     where: c.from_user_id == ^id,
     select: sum(c.amount)
  end

  @spec given_by(Ecto.Query.t) :: [Ecto.Query.t]
  def given_by(query) do
     from u in query,
     join: c in Contributr.Contribution, on: c.from_user_id == u.id,
     group_by: [u.name, u.eligible_to_give],
     select:  %{name: u.name, contributed: sum(c.amount), allowed: u.eligible_to_give},
     order_by: [asc: u.name]
  end
end
