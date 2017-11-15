defmodule Contributr.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:orgs) do
      add :name, :string
      add :active, :boolean, default: false
      add :manager_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:orgs, [:manager_id])

  end
end
