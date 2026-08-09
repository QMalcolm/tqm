defmodule Tqm.Jobs.Job do
  @moduledoc """
  Job contexts, describing jobs I've had
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :company_name, :string
    field :logo, :string
    field :url, :string
    field :description, :string
    has_many :roles, Tqm.Jobs.Role, on_replace: :delete

    timestamps()
  end

  @doc """
  Builds a changeset for a job and its roles.

  Roles are cast as a nested association: `roles_sort`/`roles_drop`
  params support dynamically adding and removing roles from a single
  form. When editing an existing job with role params, the job's roles
  must be preloaded.
  """
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:company_name, :logo, :url, :description])
    |> cast_assoc(:roles, sort_param: :roles_sort, drop_param: :roles_drop)
    |> validate_required([:company_name, :logo, :url, :description])
  end
end
