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

defmodule Contributr.UserController do
  use Contributr.Web, :controller

  alias Contributr.User
  alias Contributr.OrganizationsUsers
  alias Contributr.Organization


  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users, current_user: get_session(conn, :current_user))
  end

  def bulk_add(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "bulk_add.html", changeset: changeset, current_user: get_session(conn, :current_user))
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset, current_user: get_session(conn, :current_user))
  end

  def create(conn, %{"user" => user_params}) do
    email = String.downcase Map.get(user_params, "email")
    clean_params = Map.put(user_params, "email", email)
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        add_org_user(_user, conn)
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: get_session(conn, :current_user))
    end
  end

  def bulk_create(conn, %{"user" => user_params}) do
    emails = String.split(user_params["email"], "\r\n", trim: true)
    now =  DateTime.utc_now
    params = Enum.map(emails, fn (email) ->
    parts = String.split(email,[".","@"], trim: true)
    name = String.capitalize(Enum.at(parts,0)) <>" "<> String.capitalize(Enum.at(parts,1))
    result = %{name: name, email: email, inserted_at: now, updated_at: now}
    end)


    case Repo.insert_all(User, params, on_conflict: :nothing, returning: [:id, :inserted_at, :updated_at]) do
      {:ok, _user} ->
        #add_org_user(_user, conn)
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: get_session(conn, :current_user))
        {_, results} ->
          add_org_user(results, conn)
          conn
          |> put_flash(:info, "User created successfully.")
          |> redirect(to: user_path(conn, :index))
    end
  end

  def add_org_user(users, conn) do
    now =  DateTime.utc_now
    current_user = get_session(conn, :current_user)
    params = Enum.map(users, fn (user) ->
      result = %{user_id: user.id,
        org_id: current_user.org_id,
        role_id: 3,
        inserted_at: now,
        updated_at: now}
    end)

    Repo.insert_all(OrganizationsUsers,params, on_conflict: :nothing )
  end


  def show(conn, %{"organization" => organization, "event_id" => event_id, "id" => id}) do
    user = Repo.get!(User, id)
    check_auth(conn, user)
    render(conn, "show.html", user: user, current_user: user, organization: organization, event_id: event_id)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    check_auth(conn, user)
    changeset = User.changeset(user)

    render(conn, "edit.html", user: user, changeset: changeset, current_user: get_session(conn, :current_user))
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    check_auth(conn, user)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, current_user: get_session(conn, :current_user))
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    check_auth(conn, user)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  def check_auth(conn, user) do
    currentUser = Repo.get_by(Contributr.User , uid: get_session(conn, :current_user).uid)
    if  user.id != currentUser.id do
      msg = "You should not attempt to view that page. I'm watching you."
      conn
      |> put_flash(:error, msg)
      |> redirect(to: "/")
    end
  end
end
