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


defmodule Contributr.OrgUserCommentController do
  use Contributr.Web, :controller

  alias Contributr.User
  alias Contributr.Organization
  alias Contributr.OrganizationsUsers
  alias Contributr.Role
  alias Contributr.Contribution

  plug :scrub_params, "user" when action in [:create, :update]

  plug Contributr.Plugs.Authenticated
  plug Contributr.Plugs.OrganizationExists 
  plug Contributr.Plugs.Authorized 
  plug :put_layout, "organization.html"


  def index(conn, %{"organization" => org} ) do
    role = get_session(conn, :role)
    uid = get_session(conn, :current_user).uid

    user_id = Repo.get_by(Contributr.User, uid: uid ).id

    contributions_to_user = User.in_org(org)
    |> User.eligible_to_recieve(true)
    |> User.contributions_to()
    |> Repo.all

    contributions_to_user.abc

    case role do
      %Role{name: "Superadmin"} = r ->
        render(conn, "index.html", users: contributions_to_user, role: r.name)
      _ ->
        conn
        |> put_flash(:error, "You do not have permission to see users")
        |> redirect(to: "/")
    end
  end
end

