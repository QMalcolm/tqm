defmodule Tqm.Repo.Migrations.CascadeDeleteRolesWithJob do
  use Ecto.Migration

  def up do
    drop constraint(:roles, "roles_job_id_fkey")

    alter table(:roles) do
      modify :job_id, references(:jobs, on_delete: :delete_all)
    end
  end

  def down do
    drop constraint(:roles, "roles_job_id_fkey")

    alter table(:roles) do
      modify :job_id, references(:jobs, on_delete: :nothing)
    end
  end
end
