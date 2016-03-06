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

defmodule UserFromAuth do
  alias Ueberauth.Auth
  
  require Logger

  use Contributr.Web, :controller
  
  def find_or_create(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  def create_or_update(conn) do
    user = get_session(conn, :current_user)
    case Repo.get_by(Contributr.User, uid: user.id) do 
      nil ->
        Logger.debug "no results found"
        # create record
        changeset = %Contributr.User{name: user.name, uid: user.id, avatar_url: user.avatar, email: user.email }
        case Repo.insert(changeset) do 
          {:ok, _user} ->
            Logger.debug "inserted record!"
          {:error, changeset} ->
            Logger.error "unable to insert record" <> changeset
        end 
      %Contributr.User{} = u -> 
        Logger.debug  u.id 
        u = %{u | uid: user.id}
        Logger.debug  u.id
        case Repo.update(u) do
          {:ok, user} ->
            Logger.debug "Successfully update record" 
          {:error, changeset} ->
            Logger.error "Unable to update the user record"
        end
    end
  end

  defp basic_info(auth) do
  	%{id: auth.uid, name: name_from_auth(auth), avatar: auth.info.image, email: auth.info.email}
  end
	
	defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end
	
 
end

