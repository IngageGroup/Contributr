alias Contributr.Repo
alias Contributr.User
alias Contributr.Role
alias Contributr.Organization
alias Contributr.OrganizationsUsers




## Add Roles
sa = %Role{}
  |> Role.changeset(%{name: "Superadmin", description: "Manages this instance of Contributr"})
  |> Repo.insert!

%Role{}
  |> Role.changeset(%{name: "Manager", description: "Manages events for an organization"})
  |> Repo.insert!

%Role{}
  |> Role.changeset(%{name: "User", description: "Non elevated User"})
  |> Repo.insert!



##
## Bootstrap new applications
##
## There is probably a better way to do this, but for now,
## We will just check the database to see if there is a base org
## If not, it is assumed that this is a new install and we'll insert
## a base org and a super admin user. And put that user in the base org.
## This should be safe for existing installs.

adminUser = %User{name: "administrator", email: "",uid: UUID.uuid5(:dns,UUID.uuid1(),:hex), avatar_url: "",setup_admin: true }
user = Repo.get_by(User, name: "administrator") || Repo.insert!(adminUser)
baseOrg = %Organization{name: "base", active: true, manager_id: user.id, url: "" }
Repo.get_by(Organization, name: "base") || Repo.insert!(baseOrg)





