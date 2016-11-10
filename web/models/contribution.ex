defmodule Contributr.Contribution do
  use Contributr.Web, :model

  schema "contributions" do
    field :contr_to, :integer
    field :contr_from, :integer
    field :amount, :float
    field :comments, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:contr_to, :contr_from, :amount, :comments])
    |> validate_required([:contr_to, :contr_from, :amount, :comments])
  end
end
