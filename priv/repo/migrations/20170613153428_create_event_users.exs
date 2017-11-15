defmodule Contributr.Repo.Migrations.CreateEventUsers do
  use Ecto.Migration

  def change do
    create table(:event_users) do
      add :event_id, references(:event, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :eligible_to_receive, :boolean, default: false
      add :eligible_to_give, :float

      timestamps()
    end

  end
end
