defmodule Contributr.Repo.Migrations.RemoveEligibleFields do
  use Ecto.Migration

  def change do
    alter table(:users) do 
      remove :eligible_to_recieve
      remove :eligible_to_give
    end
  end
end
