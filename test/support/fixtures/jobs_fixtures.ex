defmodule Tqm.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tqm.Jobs` context.
  """

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        url: "some url",
        company_name: "some company_name",
        logo: "some logo",
        description: "some description"
      })
      |> Tqm.Jobs.create_job()

    job
  end

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2023-02-09],
        start_date: ~D[2023-02-09],
        title: "some title",
        details: "some details"
      })
      |> Tqm.Jobs.create_role()

    role
  end
end
