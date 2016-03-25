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

defmodule Contributr.Plugs.Authorized do
  @moduledoc """
    Plug to determine if a user has the correct authorization
  """
  import Plug.Conn
  use Contributr.Web, :controller

  alias Contributr.OrganizationsUsers

  def init(auth), do: auth 

  def call(%Plug.Conn{params: %{"organization" => org}} = conn, _auth) do 
    # is current user a member of this organization?
    IO.puts(_auth);
    user = Repo.get_by(Contributr.User, email: get_session(conn, :current_user).email) 

    query = from ou in OrganizationsUsers,
            join: o in assoc(ou, :org),
            where: ou.user_id == ^user.id and o.url == ^org,
            preload: [:role],
            select: ou

    case Repo.all(query) do
      [] -> conn |> put_flash(:error, "Not a member of this organization") |> redirect(to: "/") |> halt
      [%Contributr.OrganizationsUsers{}]= ou -> 
        role = hd(ou).role
        conn = put_session(conn, :role, role)
    end
  end

end
