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

  def convert_to_user(%Auth{} = auth) do
    info = basic_info(auth)
    {:ok, info}
  end

  def update_user_from_provider(user) do
    changeset = Contributr.User.changeset(%Contributr.User{}, user)
    case Repo.get_by(Contributr.User, email: user.email) do
      nil ->
        Logger.debug "no results found"
      %Contributr.User{} = u ->
        changeset = Contributr.User.changeset(u, user)
        case Repo.update(changeset) do
          {:ok, _user} ->
            Logger.debug "Successfully update record"
            {:ok, _user}
          {:error, _changeset} ->
            Logger.error "Unable to update the user record"
            {:error, "Unable to update the user record"}
        end
    end
  end

  def fetch_user_info(user_id) do
    case Repo.one(org_user_query(user_id)) do
      nil ->
        {:error, "No org configured for user"}
      %Contributr.OrganizationsUsers{} = ou ->
        {:ok, ou}
    end
  end

  defp basic_info(auth) do
    %{uid: auth.uid,
      name: name_from_auth(auth),
      avatar_url: auth.info.image,
      email: auth.info.email,
      access_token: auth.extra.raw_info.token.access_token,
      expires_at: auth.extra.raw_info.token.expires_at
    }
  end

  def extended_info(basic_info, ou) do
    org = ou.org
    role = ou.role
    user = ou.user
    events = load_events(ou)

    Map.merge(basic_info,
      %{org_id: org.id,
        org_name: org.name,
        role_id: role.id,
        role_name: role.name,
        user_id: user.id,
        events: events
      }
    )
  end

  defp load_events(ou) do
    events = Repo.all(event_query(ou))
    today = Date.utc_today
    e = Enum.map(events, fn(e) -> Map.merge(e, %{days_left: days_left(today, e.end_date)}) end )
    Enum.sort(e, &sort_by_time_left(&1, &2))
  end

  defp event_query(ou) do
    org = ou.org
    role = ou.role
    user = ou.user
    if role.name == "Superadmin" do
      from e in Contributr.Event,
           where: e.org_id == ^org.id,
           select: %{id: e.id, name: e.name, end_date: e.end_date , start_date: e.start_date }
    else
      from eu in Contributr.EventUsers,
           where: eu.user_id == ^user.id,
           join: e in assoc(eu, :event),
           select: %{id: e.id, name: e.name, end_date: e.end_date , start_date: e.start_date }
    end
  end

  defp sort_by_time_left(e1, e2) do
    e1.days_left >= e2.days_left
  end

  defp days_left(from_date, end_date) do
    end_date = Date.from_iso8601!(Ecto.Date.to_iso8601(end_date))
    days_left  = Date.diff(from_date,end_date)
    if days_left < 1 do 0 else days_left end
  end

  defp org_user_query(user_id) do
    from ou in Contributr.OrganizationsUsers,
         where: ou.user_id == ^user_id,
         select: ou,
         preload: [:org],
         preload: [:user],
         preload: [:role]
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

