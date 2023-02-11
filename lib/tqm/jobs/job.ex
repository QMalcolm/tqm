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
    field :work_description, :string
    has_many :roles, Tqm.Jobs.Role

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:company_name, :logo, :url, :work_description])
    |> validate_required([:company_name, :logo, :url, :work_description])
  end
end
