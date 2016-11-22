#defmodule Contributr.ContributionControllerTest do
#  use Contributr.ConnCase
#  alias Contributr.Contribution
#  @valid_attrs %{amount: 42, comments: "some content", contr_from: "some content", contr_to: "some content"}
#  @org_attrs   %{name: "someorg", url: "someorg", id: 1}
#  @invalid_attrs %{}
#
#  test "lists all entries on index", %{conn: conn} do
#    org = Repo.insert! %Contributr.Organization{}
#    conn = get conn, contribution_path(conn, :index, org), org: @org_attrs
#    assert html_response(conn, 200) =~ "Listing contributions"
#  end
#
#  test "renders form for new resources", %{conn: conn} do
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    conn = get conn, contribution_path(conn, :new, org), org: @org_attrs
#    assert html_response(conn, 200) =~ "New contribution"
#  end
#
#  test "creates resource and redirects when data is valid", %{conn: conn} do
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    conn = post conn, contribution_path(conn, :create, org), contribution: @valid_attrs
#    assert redirected_to(conn) == contribution_path(conn, :index, org)
#    assert Repo.get_by(Contribution, @valid_attrs)
#  end
#
#  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    conn = post conn, contribution_path(conn, :create, org), contribution: @invalid_attrs, org: @org_attrs
#    assert html_response(conn, 200) =~ "New contribution"
#  end
#
#  test "shows chosen resource", %{conn: conn} do
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    contribution = Repo.insert! %Contribution{}
#    conn = get conn, contribution_path(conn, :show, contribution, org), org: @org_attrs
#    assert html_response(conn, 200) =~ "Show contribution"
#  end
#
#  test "renders page not found when id is nonexistent", %{conn: conn} do
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    assert_error_sent 404, fn ->
#      get conn, contribution_path(conn, :show, -1, org)
#    end
#  end
#
#  test "renders form for editing chosen resource", %{conn: conn} do
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    contribution = Repo.insert! %Contribution{}
#    conn = get conn, contribution_path(conn, :edit, contribution, org),org: @org_attrs
#    assert html_response(conn, 200) =~ "Edit contribution"
#  end
#
#  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    contribution = Repo.insert! %Contribution{}
#    conn = put conn, contribution_path(conn, :update, contribution, org), contribution: @valid_attrs,org: @org_attrs
#    assert redirected_to(conn) == contribution_path(conn, :show, contribution, org)
#    assert Repo.get_by(Contribution, @valid_attrs)
#  end
#
#  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
#    contribution = Repo.insert! %Contribution{}
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    conn = put conn, contribution_path(conn, :update, contribution,org), contribution: @invalid_attrs,org: @org_attrs
#    assert html_response(conn, 200) =~ "Edit contribution"
#  end
#
#  test "deletes chosen resource", %{conn: conn} do
#    contribution = Repo.insert! %Contribution{}
#    org = Repo.insert! %Contributr.Organization{name: "someorg", url: "someorg", id: 1}
#    conn = delete conn, contribution_path(conn, :delete, contribution, org),org: @org_attrs
#    assert redirected_to(conn) == contribution_path(conn, :index,org)
#    refute Repo.get(Contribution, contribution.id)
#  end
#end
