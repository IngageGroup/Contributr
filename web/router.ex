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

  pipeline :admin do
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :organization do
  end

  #TODO: make a plug that only allows superadmins in here
  scope "/admin", Contributr do
    pipe_through [:browser, :admin] # Use the default browser stack
    resources "/users", UserController
    resources "/orgs", OrgController
    resources "/roles", RoleController
    resources "/:organization/events", EventController
    resources "/:organization/users", EventUsersController
    get "/:organization/event_users/:event_id", EventUsersController, :list
    get "/:organization/event_users/:event_id/:id/comments", EventUsersController, :list_comments
    get "/:organization/event_users/:event_id/new", EventUsersController, :new_event_user
    get "/:organization/event_users/:event_id/:id/edit", EventUsersController, :edit_event_user
    get "/:organization/event_users/:event_id/:id/delete", EventUsersController, :delete_event_user
    put "/:organization/event_users/:event_id/:id/update", EventUsersController, :update
    patch "/:organization/event_users/:event_id/:id/update", EventUsersController, :update
    post "/:organization/event_users/:event_id", EventUsersController, :create_event_user

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
    get "/login", LoginController, :index
  end

  scope "/:organization", Contributr do

    pipe_through [:browser, :organization]

    get "/", ApplicationController, :index

    resources "/user", UserController
    get "/user/bulk/add", UserController, :bulk_add
    post "/user/bulk/create", UserController, :bulk_create
    resources "/orgusers/:event_id", OrgUserController
    resources "/contributions/:event_id", ContributionController
    resources "/comments/:event_id", OrgUserCommentController
  end

end
