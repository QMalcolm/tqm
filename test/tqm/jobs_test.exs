defmodule Tqm.JobsTest do
  use Tqm.DataCase

  alias Tqm.Jobs

  describe "jobs" do
    alias Tqm.Jobs.Job

    import Tqm.JobsFixtures

    @invalid_attrs %{url: nil, company_name: nil, logo: nil, description: nil}

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      valid_attrs = %{
        url: "some url",
        company_name: "some company_name",
        logo: "some logo",
        description: "some description"
      }

      assert {:ok, %Job{} = job} = Jobs.create_job(valid_attrs)
      assert job.url == "some url"
      assert job.company_name == "some company_name"
      assert job.logo == "some logo"
      assert job.description == "some description"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()

      update_attrs = %{
        url: "some updated url",
        company_name: "some updated company_name",
        logo: "some updated logo",
        description: "some updated description"
      }

      assert {:ok, %Job{} = job} = Jobs.update_job(job, update_attrs)
      assert job.url == "some updated url"
      assert job.company_name == "some updated company_name"
      assert job.logo == "some updated logo"
      assert job.description == "some updated description"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end

    test "get_job!/2 preloads associations" do
      job = job_fixture()
      role = role_fixture(%{job_id: job.id})

      assert [loaded_role] = Jobs.get_job!(job.id, [:roles]).roles
      assert loaded_role.id == role.id
    end

    test "create_job/1 with nested roles creates the roles" do
      attrs = %{
        url: "some url",
        company_name: "some company_name",
        logo: "some logo",
        description: "some description",
        roles: %{
          "0" => %{
            title: "some title",
            start_date: ~D[2023-02-09],
            details: "some details"
          }
        }
      }

      assert {:ok, %Job{roles: [role]}} = Jobs.create_job(attrs)
      assert role.title == "some title"
      assert role.job_id
    end

    test "create_job/1 with invalid nested role returns error changeset" do
      attrs = %{
        url: "some url",
        company_name: "some company_name",
        logo: "some logo",
        description: "some description",
        roles: %{"0" => %{title: "some title"}}
      }

      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(attrs)
      assert Jobs.list_jobs() == []
    end

    test "update_job/2 updates nested roles" do
      job = job_fixture()
      role = role_fixture(%{job_id: job.id})
      job = Jobs.get_job!(job.id, [:roles])

      update_attrs = %{
        roles: %{"0" => %{id: role.id, title: "some updated title"}}
      }

      assert {:ok, %Job{roles: [updated_role]}} = Jobs.update_job(job, update_attrs)
      assert updated_role.id == role.id
      assert updated_role.title == "some updated title"
    end

    test "update_job/2 deletes roles removed from the association" do
      job = job_fixture()
      role = role_fixture(%{job_id: job.id})
      job = Jobs.get_job!(job.id, [:roles])

      assert {:ok, %Job{roles: []}} = Jobs.update_job(job, %{roles: %{}})
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_role!(role.id) end
    end
  end

  describe "roles" do
    alias Tqm.Jobs.Role

    import Tqm.JobsFixtures

    @invalid_attrs %{end_date: nil, start_date: nil, title: nil, details: nil}

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Jobs.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Jobs.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      valid_attrs = %{
        end_date: ~D[2023-02-09],
        start_date: ~D[2023-02-09],
        title: "some title",
        details: "some details"
      }

      assert {:ok, %Role{} = role} = Jobs.create_role(valid_attrs)
      assert role.end_date == ~D[2023-02-09]
      assert role.start_date == ~D[2023-02-09]
      assert role.title == "some title"
      assert role.details == "some details"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_role(@invalid_attrs)
    end

    test "create_role/1 associates the role with a job" do
      job = job_fixture()

      assert {:ok, %Role{} = role} =
               Jobs.create_role(%{
                 job_id: job.id,
                 start_date: ~D[2023-02-09],
                 end_date: ~D[2023-02-09],
                 title: "some title",
                 details: "some details"
               })

      assert role.job_id == job.id
    end

    test "create_role/1 with a nonexistent job returns error changeset" do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Jobs.create_role(%{
                 job_id: -1,
                 start_date: ~D[2023-02-09],
                 end_date: ~D[2023-02-09],
                 title: "some title",
                 details: "some details"
               })

      assert Keyword.has_key?(errors, :job_id)
    end

    test "create_role/1 without an end_date creates an ongoing role" do
      assert {:ok, %Role{end_date: nil}} =
               Jobs.create_role(%{
                 start_date: ~D[2023-02-09],
                 title: "some title",
                 details: "some details"
               })
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()

      update_attrs = %{
        end_date: ~D[2023-02-10],
        start_date: ~D[2023-02-10],
        title: "some updated title",
        details: "some updated details"
      }

      assert {:ok, %Role{} = role} = Jobs.update_role(role, update_attrs)
      assert role.end_date == ~D[2023-02-10]
      assert role.start_date == ~D[2023-02-10]
      assert role.title == "some updated title"
      assert role.details == "some updated details"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_role(role, @invalid_attrs)
      assert role == Jobs.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Jobs.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Jobs.change_role(role)
    end
  end
end
