defmodule Contributr.ContributionTest do
  use Contributr.ModelCase

  alias Contributr.Contribution

  @valid_attrs %{amount: 42, comments: "some content", contr_from: "some content", contr_to: "some content"}
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
