defmodule Contributr.RoleControllerTest do
  use Contributr.ConnCase

  alias Contributr.Role
  alias Contributr.User
  
  @valid_attrs %{description: "some content", name: "some content"}
  @invalid_attrs %{}

  test "unauthenticated unable to lists all entries on index", %{conn: conn} do
    conn = get conn, role_path(conn, :index)
    assert html_response(conn, 302) 
  end

  test "unauthenticated unable to render form for new resources", %{conn: conn} do
    conn = get conn, role_path(conn, :new)
    assert html_response(conn, 302)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, role_path(conn, :create), role: @invalid_attrs
    assert html_response(conn, 302)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    role = Repo.insert! %Role{}
    conn = get conn, role_path(conn, :edit, role)
    assert html_response(conn, 302)
  end

end
