defmodule Contributr.UserTest do
  use Contributr.ModelCase

  alias Contributr.User

  @valid_attrs %{avatar_url: "some content", email: "some content", name: "some content", uid: "some content", access_token: "some content", expires_at: 1234}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
