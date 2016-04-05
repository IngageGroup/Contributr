# Copyright 2016 Ingage Partners
#
# This file is part of Contributr.
#
# Contributr is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Contributr is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Contributr.  If not, see <http://www.gnu.org/licenses/>.

defmodule Contributr.Plugs.Authenticated do
  @moduledoc """
    Plug to determine if the user is currently logged in.
    It currently determines if they have a current active session and assigns
    the current_user variable.
  """

  import Plug.Conn
  use Contributr.Web, :controller

  def init(default), do: default

  def call(conn, _default) do
    case get_session(conn, :current_user) do
      nil ->
        conn |> put_flash(:error, "Unauthorized!") |> redirect(to: "/") |> halt
      %{} = user -> 
        assign(conn, :current_user, user) 
    end
  end
end
