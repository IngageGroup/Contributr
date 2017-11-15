defmodule Contributr.Repo.Migrations.MigrateContributions do
  use Ecto.Migration

  def up do
    execute """
      INSERT INTO Event (Name, Description, default_bonus, start_date, end_date, inserted_at, updated_at, org_id)
        SELECT '2016 ' || o.name || ' contribution event', '2016 ' || o.name || ' contribution event', 1000, '2016-11-01', '2016-12-10', current_timestamp, current_timestamp, o.Id 
          FROM orgs o
          LEFT JOIN Event e ON e.org_id = o.id
        WHERE e.id IS NULL
  """

    execute """
      INSERT INTO Event_Users
	        (event_id, user_id, eligible_to_receive, eligible_to_give, inserted_at, updated_at)
        SELECT e.id as event_id, u.id as user_id, u.eligible_to_recieve, u.eligible_to_give, u.inserted_at, u.updated_at
          FROM public.users u
          INNER JOIN organizations_users ou on ou.user_id = u.id
          INNER JOIN orgs o on o.id = ou.org_id
          INNER JOIN event e on e.org_id = o.id;
  """
  end

  def down do
  end
end
