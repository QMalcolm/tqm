defmodule TqmWeb.AboutLive.IndexTest do
  use TqmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Tqm.AccountsFixtures
  import Tqm.JobsFixtures

  defp create_job_with_role(job_attrs \\ %{}, role_attrs \\ %{}) do
    job = job_fixture(job_attrs)

    _role =
      role_attrs
      |> Enum.into(%{
        job_id: job.id,
        start_date: ~D[2023-01-01],
        end_date: ~D[2023-12-31],
        title: "Engineer",
        details: "Did engineering things"
      })
      |> role_fixture()

    job
  end

  describe "about page" do
    test "renders the page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/about")
      assert html =~ "Quigley"
      assert html =~ "Work, in order"
    end

    test "lists jobs with company names", %{conn: conn} do
      job = create_job_with_role(%{company_name: "Acme Corp"})
      {:ok, _lv, html} = live(conn, ~p"/about")
      assert html =~ job.company_name
    end

    test "sorts jobs by most recent start date first", %{conn: conn} do
      old_job = create_job_with_role(%{company_name: "Old Corp"}, %{start_date: ~D[2020-01-01]})
      new_job = create_job_with_role(%{company_name: "New Corp"}, %{start_date: ~D[2024-01-01]})
      {:ok, _lv, html} = live(conn, ~p"/about")
      {new_pos, _} = :binary.match(html, new_job.company_name)
      {old_pos, _} = :binary.match(html, old_job.company_name)
      assert new_pos < old_pos
    end
  end

  describe "expandable job rows" do
    test "initially hides job details", %{conn: conn} do
      create_job_with_role()
      {:ok, _lv, html} = live(conn, ~p"/about")
      refute html =~ "Did engineering things"
    end

    test "clicking job row expands details", %{conn: conn} do
      job = create_job_with_role()
      {:ok, lv, _html} = live(conn, ~p"/about")
      lv |> element("#job-#{job.id}") |> render_click()
      assert render(lv) =~ "Did engineering things"
    end

    test "clicking an expanded job row collapses it", %{conn: conn} do
      job = create_job_with_role()
      {:ok, lv, _html} = live(conn, ~p"/about")
      lv |> element("#job-#{job.id}") |> render_click()
      lv |> element("#job-#{job.id}") |> render_click()
      refute render(lv) =~ "Did engineering things"
    end

    test "lists a job's roles newest first", %{conn: conn} do
      job = job_fixture()

      # Insert the older role first so a database that returns insertion
      # order would show it first without explicit sorting. Match on the
      # details rather than the titles: the newest role's title also
      # appears in the collapsed row header, above both role entries.
      role_fixture(%{
        job_id: job.id,
        title: "Junior Engineer",
        start_date: ~D[2020-01-01],
        end_date: ~D[2022-01-01],
        details: "Older role details"
      })

      role_fixture(%{
        job_id: job.id,
        title: "Staff Engineer",
        start_date: ~D[2022-01-02],
        end_date: nil,
        details: "Newer role details"
      })

      {:ok, lv, _html} = live(conn, ~p"/about")
      html = lv |> element("#job-#{job.id}") |> render_click()

      {newer_pos, _} = :binary.match(html, "Newer role details")
      {older_pos, _} = :binary.match(html, "Older role details")
      assert newer_pos < older_pos
    end

    test "job without roles renders without crashing", %{conn: conn} do
      job = job_fixture(%{company_name: "Roleless Corp"})
      {:ok, _lv, html} = live(conn, ~p"/about")
      assert html =~ job.company_name
    end
  end

  describe "owner affordances" do
    test "owner sees add and edit job links", %{conn: conn} do
      job = create_job_with_role()
      conn = log_in_person(conn, owner_person_fixture())

      {:ok, lv, html} = live(conn, ~p"/about")
      assert html =~ "add job"

      html = lv |> element("#job-#{job.id}") |> render_click()
      assert html =~ "edit job"
      assert html =~ "/about/jobs/#{job.id}/edit"
    end

    test "visitors see no edit affordances", %{conn: conn} do
      job = create_job_with_role()

      {:ok, lv, html} = live(conn, ~p"/about")
      refute html =~ "add job"

      html = lv |> element("#job-#{job.id}") |> render_click()
      refute html =~ "edit job"
    end
  end
end
