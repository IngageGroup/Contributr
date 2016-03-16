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
defmodule UserFromAuth do
  alias Ueberauth.Auth
  
  require Logger

  use Contributr.Web, :controller
  
  def find_or_create(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  def create_or_update(conn, user) do
    #user = get_session(conn, :current_user)
    #user = %{name: user.name, uid: user.id, avatar_url: user.avatar, email: user.email }
    changeset = Contributr.User.changeset(%Contributr.User{}, user)
    case Repo.get_by(Contributr.User, email: user.email) do 
      nil ->
        Logger.debug "no results found"
        # create record
        case Repo.insert(changeset) do 
          {:ok, _user} ->
            Logger.debug "inserted record!"
          {:error, changeset} ->
            Logger.error "unable to insert record" <> changeset
        end 
      %Contributr.User{} = u -> 
        #update = %{uid: user.uid, access_token: user.access_token}
        changeset = Contributr.User.changeset(u, user)
        case Repo.update(changeset) do
          {:ok, user} ->
            Logger.debug "Successfully update record" 
          {:error, changeset} ->
            Logger.error "Unable to update the user record"
        end
    end
  end

  defp basic_info(auth) do
    #IO.inspect(auth)
  	%{uid: auth.uid, 
      name: name_from_auth(auth), 
      avatar_url: auth.info.image, 
      email: auth.info.email, 
      access_token: auth.extra.raw_info.token.access_token,
      expires_at: auth.extra.raw_info.token.expires_at
    }
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

