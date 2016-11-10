defmodule Contributr.Repo.Migrations.CreateContribution do
  use Ecto.Migration

  def change do
    create table(:contributions) do
      add :contr_to, references(:users, on_delete: :nothing)
      add :contr_from, references(:users, on_delete: :nothing)
      add :amount, :float
      add :comments, :string

      timestamps()
    end

  end
end
