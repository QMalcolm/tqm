defmodule Tqm.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :company_name, :string
      add :logo, :string
      add :url, :string
      add :work_description, :text

      timestamps()
    end
  end
end
