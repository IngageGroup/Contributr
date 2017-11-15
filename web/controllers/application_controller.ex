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
defmodule Contributr.ApplicationController do
  @moduledoc """
    The main functionality of contributr lives here.
  """
  use Contributr.Web, :controller
  alias Contributr.Organization
  
  plug Contributr.Plugs.Authenticated
  plug Contributr.Plugs.Authorized 
  plug :put_layout, "organization.html"

  def index(conn, %{"organization" => orgname}) do
    role = get_session(conn, :role)
    render conn, "index.html", org_name: orgname, role: role.name
  end

end
