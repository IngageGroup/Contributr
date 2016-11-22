defmodule Contributr.ContributionTest do
  use Contributr.ModelCase

  alias Contributr.Contribution

  @valid_attrs %{amount: 42, comments: "some content some content", from_user_id: 1, to_user_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Contribution.changeset(%Contribution{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Contribution.changeset(%Contribution{}, @invalid_attrs)
    refute changeset.valid?
  end
end
