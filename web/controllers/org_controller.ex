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

defmodule Contributr.OrgController do
  use Contributr.Web, :controller

  alias Contributr.User
  alias Contributr.Organization

  plug :scrub_params, "organization" when action in [:create, :update]
  
  def index(conn, _params) do
    orgs = Organization |> Repo.all |> Repo.preload [:manager]
    render(conn, "index.html", orgs: orgs, current_user: get_session(conn, :current_user))
  end

  def new(conn, _params) do
    changeset = Organization.changeset(%Organization{})
    register_users = User |> Repo.all
    render(conn, "new.html", changeset: changeset, current_user: get_session(conn, :current_user), users: register_users)
  end

  def create(conn, %{"organization" => org_params}) do
    changeset = Organization.changeset(%Organization{}, org_params)
    IO.inspect(changeset)
    case Repo.insert(changeset) do
      {:ok, _org} ->
        conn
        |> put_flash(:info, "Organization created successfully.")
        |> redirect(to: org_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: get_session(conn, :current_user))
    end
  end



end
