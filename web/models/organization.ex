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

defmodule Contributr.Organization do
  use Contributr.Web, :model

  schema "orgs" do
    field :name, :string
    field :url, :string
    field :active, :boolean, default: false
    belongs_to :manager, Contributr.User

    has_many :organizations_users, Contributr.OrganizationsUsers
    timestamps
  end

  @required_fields ~w(name active url)
  @optional_fields ~w(manager_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:url, ~r/[a-z0-9_]/)
    |> unique_constraint(:url)
  end
end
