defmodule Contributr.Repo.Migrations.Add_Events do
  use Ecto.Migration

  def change do
     create table(:event) do
        add :name, :string
        add :description, :string
        add :default_bonus, :float
        add :start_date, :date
        add :end_date, :date

        timestamps()
     end



     alter table(:contributions) do
        add :event_id, references(:event, on_delete: :nothing)
     end &
  end
end
