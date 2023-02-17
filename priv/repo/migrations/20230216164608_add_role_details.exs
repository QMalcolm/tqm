defmodule Tqm.Repo.Migrations.AddRoleDescriptions do
  use Ecto.Migration

  def change do
    alter table(:roles) do
      add :details, :text
    end
  end
end
