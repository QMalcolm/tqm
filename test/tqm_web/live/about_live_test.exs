defmodule TqmWeb.AboutLive.IndexTest do
  use TqmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Tqm.JobsFixtures

  # The role_fixture doesn't associate roles with jobs (job_id isn't cast by
  # Role.changeset), so we need to set it explicitly.
  defp create_job_with_role(job_attrs \\ %{}, role_attrs \\ %{}) do
    job = job_fixture(job_attrs)

    role_attrs =
      Enum.into(role_attrs, %{
        start_date: ~D[2023-01-01],
        end_date: ~D[2023-12-31],
        title: "Engineer",
        details: "Did engineering things"
      })

    {:ok, _role} =
      %Tqm.Jobs.Role{}
      |> Tqm.Jobs.Role.changeset(role_attrs)
      |> Ecto.Changeset.put_change(:job_id, job.id)
      |> Tqm.Repo.insert()

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

  describe "JobWithTogglableDetails component" do
    test "initially hides job details", %{conn: conn} do
      create_job_with_role()
      {:ok, _lv, html} = live(conn, ~p"/about")
      refute html =~ "Did engineering things"
    end

    test "clicking job summary toggles details visibility", %{conn: conn} do
      job = create_job_with_role()
      {:ok, lv, _html} = live(conn, ~p"/about")
      lv |> element("#job-#{job.id}") |> render_click()
      assert render(lv) =~ "Did engineering things"
    end
  end
end
