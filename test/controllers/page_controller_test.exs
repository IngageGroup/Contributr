defmodule Contributr.PageControllerTest do
  use Contributr.ConnCase

  test "GET /" do
    conn = get build_conn, "/"
    assert html_response(conn, 302) =~ "redirected"
  end
end
