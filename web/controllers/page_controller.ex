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

defmodule Contributr.PageController do
  use Contributr.Web, :controller

  def index(conn, _params) do
    current_user = get_session(conn, :current_user)
    if current_user == nil do
      # not logged in....
      conn
      |> put_flash(:error, "You must log in first")
      |> redirect(to: "/login")
    else
      uid = current_user.uid
      user = Repo.get_by(Contributr.User, uid: uid)
      orguser = Repo.get_by(Contributr.OrganizationsUsers, user_id: user.id)
      role = Repo.get_by(Contributr.Role, id: orguser.role_id)
      org = Repo.get_by(Contributr.Organization, id: orguser.org_id)

      event = Repo.one(
        from e in Contributr.Event,
        where: e.org_id == ^orguser.org_id,
        order_by: [desc: e.end_date],
        limit: 1)

      if event != nil do
        render conn, "index.html",
               current_user: user,
               organization: org,
               event_id: event.id,
               role: role
      else
        conn
        |> put_flash(:error, "User has no assigned events")
        |> redirect(to: "/login")

      end
    end
  end
end
