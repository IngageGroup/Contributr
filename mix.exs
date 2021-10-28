defmodule Contributr.Mixfile do
  use Mix.Project

  def project do
    [app: :contributr,
      version: "0.0.1",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Contributr, []},
      applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
        :phoenix_ecto, :postgrex, :ueberauth, :ueberauth_google, :number]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.6.2"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.7.1"},
      {:postgrex, ">= 0.15.13"},
      {:phoenix_html, "~> 3.0.4"},
      {:phoenix_live_reload, "~> 1.3.3", only: :dev},
      {:gettext, "~> 0.18.2"},
      {:cowboy, "~> 2.9.0"},
      {:plug_cowboy, "~> 2.5.2"},
      {:ueberauth, "~> 0.6.3"},
      {:ueberauth_google, "~> 0.10.0"},
      {:dialyxir, "~> 1.1.0", only: [:dev]},
      {:number, "~> 1.0.3"},
      {:uuid, "~> 1.1.8"},
      {:plug, "~> 1.12.1"},
      {:poison, "~> 3.1"}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
