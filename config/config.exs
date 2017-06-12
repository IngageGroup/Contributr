# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :contributr, Contributr.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XBI6919dN7VbYIB1DASLayDH+WB5ycdH1XWY44roC90D+DroyuOmGClLxJ1TVjOH",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Contributr.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :contributr, ecto_repos: [Contributr.Repo]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, ["email profile https://www.googleapis.com/auth/admin.directory.customer.readonly"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "581534349443-rve7c82khcg005se9pjkl66bumcrpjai.apps.googleusercontent.com",
  client_secret: "W02uqDImXX-CQKXXgxWNmw8i",
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

