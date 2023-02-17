defmodule Tqm.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :title, :string
      add :start_date, :date
      add :end_date, :date
      add :job_id, references(:jobs, on_delete: :nothing)

      timestamps()
    end

    create index(:roles, [:job_id])
  end
end
