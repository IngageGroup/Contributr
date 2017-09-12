defmodule Contributr.Repo.Migrations.CreateOrganizations_Users do
  use Ecto.Migration

  def change do
    create table(:organizations_users) do
      add :org_id, references(:orgs, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end
    create index(:organizations_users, [:org_id])
    create index(:organizations_users, [:user_id])

  end
end
