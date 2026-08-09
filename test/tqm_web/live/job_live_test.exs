defmodule TqmWeb.JobLive.FormTest do
  use TqmWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tqm.AccountsFixtures
  import Tqm.JobsFixtures

  @create_attrs %{
    company_name: "Acme Corp",
    url: "https://acme.example",
    logo: "images/acme-logo.png",
    description: "Makes anvils"
  }

  @role_attrs %{
    title: "Anvil Engineer",
    start_date: "2024-01-01",
    end_date: "",
    details: "Dropped anvils"
  }

  describe "access control" do
    test "redirects anonymous and non-owner visitors", %{conn: conn} do
      job = job_fixture()
      stranger = stranger_person_fixture()
      non_stranger = non_stranger_person_fixture()

      for path <- [~p"/about/jobs/new", ~p"/about/jobs/#{job.id}/edit"] do
        assert {:error, {:redirect, %{to: "/"}}} = live(conn, path)

        assert {:error, {:redirect, %{to: "/"}}} =
                 conn |> log_in_person(stranger) |> live(path)

        assert {:error, {:redirect, %{to: "/"}}} =
                 conn |> log_in_person(non_stranger) |> live(path)
      end
    end
  end

  describe "new job" do
    setup %{conn: conn} do
      %{conn: log_in_person(conn, owner_person_fixture())}
    end

    test "renders form", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/about/jobs/new")
      assert html =~ "New <em>job</em>"
    end

    test "creates a job with a role", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/about/jobs/new")

      # Simulate clicking "+ Add role", which submits a change event with an
      # extra roles_sort entry.
      html = render_change(lv, "validate", %{"job" => %{"roles_sort" => ["new"]}})
      assert html =~ "job[roles][0][title]"

      assert {:error, {:live_redirect, %{to: "/about"}}} =
               lv
               |> form("#job_form", job: Map.put(@create_attrs, :roles, %{"0" => @role_attrs}))
               |> render_submit()

      assert [job] = Tqm.Jobs.list_jobs([:roles])
      assert job.company_name == "Acme Corp"
      assert [%{title: "Anvil Engineer", end_date: nil}] = job.roles
    end

    test "renders errors on invalid submit", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/about/jobs/new")

      html =
        lv
        |> form("#job_form", job: %{@create_attrs | company_name: ""})
        |> render_submit()

      assert html =~ "Please fix the errors below before saving."
      assert html =~ "can&#39;t be blank"
      assert Tqm.Jobs.list_jobs() == []
    end
  end

  describe "edit job" do
    setup %{conn: conn} do
      job = job_fixture(%{company_name: "Acme Corp"})
      role = role_fixture(%{job_id: job.id, title: "Anvil Engineer"})
      %{conn: log_in_person(conn, owner_person_fixture()), job: job, role: role}
    end

    test "renders form with existing data", %{conn: conn, job: job} do
      {:ok, _lv, html} = live(conn, ~p"/about/jobs/#{job.id}/edit")
      assert html =~ "Acme Corp"
      assert html =~ "Anvil Engineer"
    end

    test "updates the job and its role", %{conn: conn, job: job, role: role} do
      {:ok, lv, _html} = live(conn, ~p"/about/jobs/#{job.id}/edit")

      assert {:error, {:live_redirect, %{to: "/about"}}} =
               lv
               |> form("#job_form",
                 job: %{
                   company_name: "Acme Corp International",
                   roles: %{"0" => %{id: role.id, title: "Chief Anvil Officer"}}
                 }
               )
               |> render_submit()

      updated = Tqm.Jobs.get_job!(job.id, [:roles])
      assert updated.company_name == "Acme Corp International"
      assert [%{title: "Chief Anvil Officer"}] = updated.roles
    end

    test "removes a role dropped from the form", %{conn: conn, job: job, role: role} do
      {:ok, lv, _html} = live(conn, ~p"/about/jobs/#{job.id}/edit")

      # Simulate clicking "Remove role", which submits a change event with the
      # role's index in roles_drop.
      html = render_change(lv, "validate", %{"job" => %{"roles_drop" => ["0"]}})
      refute html =~ "job[roles][0][title]"

      assert {:error, {:live_redirect, %{to: "/about"}}} =
               lv
               |> form("#job_form", job: %{company_name: "Acme Corp"})
               |> render_submit()

      assert Tqm.Jobs.get_job!(job.id, [:roles]).roles == []
      assert_raise Ecto.NoResultsError, fn -> Tqm.Jobs.get_role!(role.id) end
    end

    test "deletes the job", %{conn: conn, job: job} do
      {:ok, lv, _html} = live(conn, ~p"/about/jobs/#{job.id}/edit")

      assert {:error, {:live_redirect, %{to: "/about"}}} =
               lv
               |> element("button", "Delete job")
               |> render_click()

      assert Tqm.Jobs.list_jobs() == []
    end
  end
end
