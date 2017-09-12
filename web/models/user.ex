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
    field :setup_admin, :boolean, default: false
    
    has_many :orgs, Contributr.Organization
    has_many :organizations_users, Contributr.OrganizationsUsers

    timestamps
  end

  @required_fields ~w(name email)
  @optional_fields ~w(uid access_token expires_at avatar_url setup_admin)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
 #   |> validate_number(:eligible_to_give, greater_than_or_equal_to: 0)
  end

  @spec in_org(String.t) :: [Ecto.Query.t]
  def in_org(org_url) do
    from u in Contributr.User,
      join: ou in assoc(u, :organizations_users),
      join: o in assoc(ou, :org),
      where: o.url == ^org_url
  end

#  @spec eligible_to_recieve(Ecto.Query.t, Boolean.t) :: [Ecto.Query.t]
#  def eligible_to_recieve(query, status) do
#    from u in query,
#      where: u.eligible_to_recieve == ^status
#  end
#
#  @spec eligible_to_give_more_than(Ecto.Query.t, Integer.t) :: [Ecto.Query.t]
#  def eligible_to_give_more_than(query, amount) do
#    from u in query,
#      where: u.eligible_to_give > ^amount
#  end

#  @spec contributions_from(Ecto.Query.t) :: [Ecto.Query.t]
#  def contributions_from(query) do
#     from u in query,
#         left_join: c in Contributr.Contribution,  on: c.from_user_id == u.id ,
#         group_by: [u.name, u.id, u.eligible_to_give, u.email],
#         select:  %{
#                    id: u.id,
#                    name: u.name,
#                    contributed: sum(c.amount),
#                    allowed: u.eligible_to_give,
#                    email: u.email, received: sum(c.amount)},
#         order_by: [asc: u.name]
#  end

  @spec contributions_to(Ecto.Query.t, String.t) :: [Ecto.Query.t]
  def contributions_to(query, id) do
     from u in query,
         left_join: c in Contributr.Contribution,  on: c.to_user_id == ^id,
         select:  sum(c.amount)
  end

  @spec has_comments(Ecto.Query.t) :: [Ecto.Query.t]
  def has_comments(query) do
     from u in query,
         inner_join: c in Contributr.Contribution,  on: c.to_user_id == u.id,
         distinct: u.id,
         select:  %{name: u.name, id: u.id},
         order_by: [asc: u.name]
  end
end
