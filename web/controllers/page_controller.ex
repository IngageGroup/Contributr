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
      render conn, "index.html", user_id: "", org_name: "", org_url: "", current_user: current_user
    else
      uid = current_user.uid
      user = Repo.get_by(Contributr.User, uid: uid)
      orguser = Repo.get_by(Contributr.OrganizationsUsers, user_id: user.id)
      org = Repo.get_by(Contributr.Organization, id: orguser.org_id)
      render conn, "index.html",
            user_id: user.id,
            org_name: org.name,
            org_url: org.url,
            current_user: user,
            organization: org
    end


  end
end
