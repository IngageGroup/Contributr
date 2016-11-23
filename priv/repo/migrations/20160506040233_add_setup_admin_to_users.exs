defmodule Contributr.Repo.Migrations.AddSetupAdminToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do 
      add :setup_admin, :boolean, default: false
    end
  end
end
