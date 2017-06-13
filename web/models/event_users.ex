defmodule Contributr.EventUsers do
  use Contributr.Web, :model

  schema "event_users" do
    field :event_id, :integer
    field :user_id, :integer
    field :eligible_to_receive, :boolean, default: false
    field :eligible_to_give, :float

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event_id, :user_id, :eligible_to_receive, :eligible_to_give])
    |> validate_required([:event_id, :user_id, :eligible_to_receive, :eligible_to_give])
  end
end
