defmodule Contributr.Event do
  use Contributr.Web, :model

  schema "event" do
    field :name, :string
    field :description, :string
    field :default_bonus, :float
    field :start_date, Ecto.Date
    field :end_date, Ecto.Date
    belongs_to :org, Contributr.Organization

    has_many :event_users, Contributr.EventUsers

    timestamps()
  end

  @required_fields ~w(name default_bonus start_date end_date)
  @optional_fields ~w(description)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:name, min: 1, max: 255)
    |> validate_number(:default_bonus, greater_than_or_equal_to: 0)
  end

  @spec has_user(Ecto.Query.t, String.t, String.t) :: [Ecto.Query.t]
  def has_user(query, event_id, user_id) do
    from u in query,
      join: eu in assoc(u, :event_users),
      join: e in assoc(eu, :event),
      where: u.id == ^user_id and e.id == ^event_id
  end

end