ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Contributr.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Contributr.Repo --quiet)

Ecto.Adapters.SQL.Sandbox.mode(Contributr.Repo, :manual)
