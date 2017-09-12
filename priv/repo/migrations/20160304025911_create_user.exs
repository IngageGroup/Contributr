defmodule Contributr.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :uid, :string
      add :avatar_url, :string

      timestamps()
    end

  end
end
