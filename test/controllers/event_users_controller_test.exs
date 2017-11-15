defmodule Contributr.EventUsersControllerTest do
  use Contributr.ConnCase

  alias Contributr.EventUsers
  @valid_attrs %{eligible_to_give: "120.5", eligible_to_receive: true, event_id: 42, user_id: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, event_users_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing event users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, event_users_path(conn, :new)
    assert html_response(conn, 200) =~ "New event users"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, event_users_path(conn, :create), event_users: @valid_attrs
    assert redirected_to(conn) == event_users_path(conn, :index)
    assert Repo.get_by(EventUsers, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, event_users_path(conn, :create), event_users: @invalid_attrs
    assert html_response(conn, 200) =~ "New event users"
  end

  test "shows chosen resource", %{conn: conn} do
    event_users = Repo.insert! %EventUsers{}
    conn = get conn, event_users_path(conn, :show, event_users)
    assert html_response(conn, 200) =~ "Show event users"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, event_users_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    event_users = Repo.insert! %EventUsers{}
    conn = get conn, event_users_path(conn, :edit, event_users)
    assert html_response(conn, 200) =~ "Edit event users"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    event_users = Repo.insert! %EventUsers{}
    conn = put conn, event_users_path(conn, :update, event_users), event_users: @valid_attrs
    assert redirected_to(conn) == event_users_path(conn, :show, event_users)
    assert Repo.get_by(EventUsers, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    event_users = Repo.insert! %EventUsers{}
    conn = put conn, event_users_path(conn, :update, event_users), event_users: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit event users"
  end

  test "deletes chosen resource", %{conn: conn} do
    event_users = Repo.insert! %EventUsers{}
    conn = delete conn, event_users_path(conn, :delete, event_users)
    assert redirected_to(conn) == event_users_path(conn, :index)
    refute Repo.get(EventUsers, event_users.id)
  end
end
