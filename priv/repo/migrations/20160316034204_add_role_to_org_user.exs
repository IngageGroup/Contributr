defmodule Contributr.Repo.Migrations.AddRoleToOrgUser do
  use Ecto.Migration

  def change do
    alter table(:organizations_users) do
      add :role_id, references(:roles, on_delete: :nothing)
    end

    create index(:organizations_users, [:role_id])
  end
end
