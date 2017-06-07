defmodule Contributr.EventUsers do
  use Contributr.Web, :model

  schema "event_users" do
    belongs_to :event, Contributr.Event
    belongs_to :user, Contributr.User
    field :eligible_to_receive, :boolean, default: false
    field :eligible_to_send, :boolean, default: false

  end

  @required_fields ~w(event_id user_id eligible_to_receive eligible_to_send)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def from_event(query, event) do
    from eu in query,
      join: u in assoc(ou, :user),
      join: e in assoc(ou, :event),
      where: e.id == ^event,
      order_by: [asc: u.name],
      select: eu
  end
end