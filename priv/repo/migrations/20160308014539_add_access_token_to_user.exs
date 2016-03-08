defmodule Contributr.Repo.Migrations.AddAccessTokenToUser do
  use Ecto.Migration

  def change do
  	alter table(:users) do
   		add :access_token, :string
  		add :expires_at, :integer
		end
	end
end
