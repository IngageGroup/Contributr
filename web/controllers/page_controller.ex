defmodule Contributr.PageController do
  use Contributr.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
