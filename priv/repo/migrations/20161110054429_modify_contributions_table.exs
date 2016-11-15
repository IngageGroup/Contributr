defmodule Contributr.Repo.Migrations.ModifyContributionsTable do
  use Ecto.Migration

  def change do
  rename table(:contributions), :contr_from, to: :from_user_id
  rename table(:contributions), :contr_to,   to: :to_user_id
  end
end
