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
    |> validate_length(:comments, min: 20)
  end


end
