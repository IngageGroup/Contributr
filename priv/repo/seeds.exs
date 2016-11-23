alias Contributr.Repo
alias Contributr.User
alias Contributr.Role

superadmin = %Role{}
              |> Role.changeset(%{name: "Superadmin", description: "Superadmin has access to everything"})
              |> Repo.insert!

manager = %Role{}
          |> Role.changeset(%{name: "Manager", description: "The manager(s) of an organization"})
          |> Repo.insert!

