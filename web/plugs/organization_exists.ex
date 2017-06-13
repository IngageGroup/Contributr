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

defmodule Contributr.Plugs.OrganizationExists do
  require Logger

  @moduledoc """
    Plug to determine if an organization exists 
  """
 use Contributr.Web, :controller

  alias Contributr.Organization
  
  def init(default), do: default

  def call(%Plug.Conn{params: %{"organization" => org}} = conn, _default) do 
            Logger.info "Var value: #{inspect(conn.params["organization"])}"
    case Repo.get_by(Organization, url: conn.params["organization"]) do 
          nil -> conn |> put_flash(:error, "Organization not found") |> redirect(to: "/") |> halt
          %Organization{} = org -> assign(conn, :organization, org)
        end
  end

end
