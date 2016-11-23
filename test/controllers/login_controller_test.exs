defmodule Contributr.LoginControllerTest do
  use Contributr.ConnCase


  test "GET /" do
    conn = get build_conn, "/login"
    assert html_response(conn, 200)
  end
end
