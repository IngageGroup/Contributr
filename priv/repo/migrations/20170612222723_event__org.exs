defmodule Contributr.Repo.Migrations.Event_Org do
  use Ecto.Migration

  def change do
    alter table(:event) do
      add :org_id, references(:orgs, on_delete: :nothing)
    end
  end
end
