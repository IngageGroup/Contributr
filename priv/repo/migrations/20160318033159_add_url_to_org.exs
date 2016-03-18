defmodule Contributr.Repo.Migrations.AddUrlToOrg do
  use Ecto.Migration

  def change do
    alter table(:orgs) do
      add :url, :string
    end
  end
end
