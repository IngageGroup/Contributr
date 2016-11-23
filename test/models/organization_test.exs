defmodule Contributr.OrganizationTest do
  use Contributr.ModelCase

  alias Contributr.Organization

  @valid_attrs %{active: true, name: "some content", url: "asdf89_"}
  @invalid_attrs %{url: "sdf asdfa "}

  test "changeset with valid attributes" do
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Organization.changeset(%Organization{}, @invalid_attrs)
    refute changeset.valid?
  end
end
