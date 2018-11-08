defmodule Contributr.Plugs.CheckPermission do
  @moduledoc """
    Plug to determine if the user has the necessary role.    
  """
  import Plug.Conn
  use Contributr.Web, :controller

  alias Contributr.CheckPermission

  def init(opts) do
    Keyword.fetch(opts, :allowedRole)
  end

  def call(conn, allowedRole) do
    user = get_session(conn, :current_user)
    if !allowed?(user.role_name) do
      conn
      |> put_flash(:error, "User is not authorized to access this resource")
      |> redirect(to: "/")
      |> halt
    end
  end

  def allowed?(role) do
    case role do
      "Superadmin" -> true
      "Manager" -> true
      _ -> false
    end
  end
end
