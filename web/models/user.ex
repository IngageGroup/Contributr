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

defmodule Contributr.User do
  use Contributr.Web, :model
  import Ecto.Query

  schema "users" do
    field :name, :string
    field :email, :string
    field :uid, :string
    field :avatar_url, :string
    field :access_token, :string
    field :expires_at, :integer
    field :eligible_to_recieve, :boolean, default: false
    field :eligible_to_give, :float
    
    has_many :orgs, Contributr.Organization
    has_many :organizations_users, Contributr.OrganizationsUsers

    timestamps
  end

  @required_fields ~w(name email)
  @optional_fields ~w(uid access_token expires_at avatar_url eligible_to_recieve eligible_to_give)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  @spec users_in_org(Ecto.Query.t, String.t) :: [Ecto.Query.t]
  def users_in_org(query, orgname) do 
    from u in query,
      join: ou in assoc(u, :organizations_users),
      join: o in assoc(ou, :org),
      where: o.url == ^orgname,
      order_by: [asc: u.name],
      select: u
  end
end
