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
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

defmodule Contributr.AuthController do

  use Contributr.Web, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
		render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

	def delete(conn, _params) do
		conn
		|> put_flash(:info, "You have been logged out!")
		|> configure_session(drop: true)
		|> redirect(to: "/")
	end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
     |> put_flash(:error, "Failed to authenticate.")
     |> redirect(to: "/")
  end

 	def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        UserFromAuth.create_or_update(conn, user)
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end 

end
