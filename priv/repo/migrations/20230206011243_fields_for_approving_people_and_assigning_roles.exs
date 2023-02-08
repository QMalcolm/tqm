defmodule Tqm.Repo.Migrations.GivePeopleRolesAndApproval do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :role, :string, null: false, default: "stranger"
      add :approved, :boolean, null: false, default: false
    end
  end
end
