defmodule Tqm.Jobs.Role do
  @moduledoc """
  Role contexts, describing roles related to jobs
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :end_date, :date
    field :start_date, :date
    field :title, :string
    field :job_id, :id
    field :details, :string

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:title, :start_date, :end_date, :details])
    |> validate_required([:title, :start_date, :end_date, :details])
  end
end
