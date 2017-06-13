defmodule Contributr.EventUsersTest do
  use Contributr.ModelCase

  alias Contributr.EventUsers

  @valid_attrs %{eligible_to_give: "120.5", eligible_to_receive: true, event_id: 42, user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EventUsers.changeset(%EventUsers{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EventUsers.changeset(%EventUsers{}, @invalid_attrs)
    refute changeset.valid?
  end
end
