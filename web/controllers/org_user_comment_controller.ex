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
  alias Contributr.Role
  alias Contributr.Contribution

  plug :scrub_params, "user" when action in [:create, :update]

  plug Contributr.Plugs.Authenticated
  plug Contributr.Plugs.OrganizationExists
  plug Contributr.Plugs.Authorized
  plug :put_layout, "organization.html"


  def index(conn, %{"organization" => org, "event_id" => event_id} ) do
    role = get_session(conn, :role)
    comments_for_user = User.in_org(org)
                        #|> User.eligible_to_recieve(true)
                        |> User.has_comments()
                        |> Repo.all

    case role do
      %Role{name: "Admin"} = r ->
        render(conn, "index.html", users: comments_for_user, role: r.name)
      _ ->
        conn
        |> put_flash(:error, "You do not have permission to see users")
        |> redirect(to: "/")
    end
  end


  def show(conn, %{"id" => id }) do
    role = get_session(conn, :role)
    user = Repo.get_by(Contributr.User, id: id )
    comments_for_user = Contributr.Contribution
                        |> Contribution.comments_for(id)
                        |> Repo.all

    case role do
      %Role{name: "Admin"} ->
        render(conn, "show.html", comments: comments_for_user, user: user)
      _ ->
        conn
        |> put_flash(:error, "You do not have permission to see users")
        |> redirect(to: "/")
    end
  end

end

