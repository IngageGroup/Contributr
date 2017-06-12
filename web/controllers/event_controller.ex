defmodule Contributr.EventController do
  import Number
  require Number.Macros
  use Contributr.Web, :controller

  alias Contributr.Event
  alias Contributr.User

def index(conn, %{"organization" => organization}) do
    events = org_events(conn, organization)
    render(conn, "index.html", events: events)
  end

    def org_events(conn, orgname) do
      Repo.all(
        from e in Contributr.Event,
        join: o in assoc(e, :org),
        where: o.name == ^orgname,
        select: e
      )
    end
end