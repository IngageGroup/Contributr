defmodule Contributr.Repo.Migrations.AddEligibilityToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do 
      add :eligible_to_recieve, :boolean, default: false
      add :eligible_to_give, :float
    end
  end
end
