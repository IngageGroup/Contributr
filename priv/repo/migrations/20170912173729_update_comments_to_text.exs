defmodule Contributr.Repo.Migrations.UpdateCommentsToText do
  use Ecto.Migration

  def change do
    alter table(:contributions) do
      modify :comments, :text
    end

  end
end
