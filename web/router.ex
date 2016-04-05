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
defmodule Contributr.Router do
  use Contributr.Web, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :organization do
    # eventually figure out how to create plugs 
    # that I can add here
  end

  #TODO: make a plug that only allows superadmins in here
  scope "/admin", Contributr do
    pipe_through :browser # Use the default browser stack

    resources "/users", UserController
    resources "/orgs", OrgController
    resources "/roles", RoleController
  end

  scope "/auth", Contributr do
    pipe_through [:browser]

    get "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  scope "/", Contributr do
    pipe_through [:browser]

    # the home page
    get "/", PageController, :index

  end

  scope "/:organization", Contributr do 

    pipe_through [:browser,:organization]

    get "/", ApplicationController, :index
    resources "/users", OrgUserController 
  end

  # Other scopes may use custom stacks.
  # scope "/api", Contributr do
  #   pipe_through :api
  # end
end
