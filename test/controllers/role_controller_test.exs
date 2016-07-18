defmodule Contributr.RoleControllerTest do
  use Contributr.ConnCase

  alias Contributr.Role

  @valid_attrs %{description: "some content", name: "some content"}
  @invalid_attrs %{}

  test "unauthenticated unable to lists all entries on index" do
    conn = get build_conn, role_path(build_conn, :index)
    assert html_response(conn, 302) 
  end

  test "unauthenticated unable to render form for new resources" do
    conn = get build_conn, role_path(build_conn, :new)
    assert html_response(conn, 302)
  end

  test "does not create resource and renders errors when data is invalid" do
    conn = post build_conn, role_path(build_conn, :create), role: @invalid_attrs
    assert html_response(conn, 302)
  end

  test "renders form for editing chosen resource" do
    role = Repo.insert! %Role{}
    conn = get build_conn, role_path(build_conn, :edit, role)
    assert html_response(conn, 302)
  end

end
