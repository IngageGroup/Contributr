defmodule Contributr.Organizations_UsersTest do
  use Contributr.ModelCase

  alias Contributr.OrganizationsUsers

  @valid_attrs %{user_id: 1, role_id: 2, org_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OrganizationsUsers.changeset(%OrganizationsUsers{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OrganizationsUsers.changeset(%OrganizationsUsers{}, @invalid_attrs)
    refute changeset.valid?
  end
end
