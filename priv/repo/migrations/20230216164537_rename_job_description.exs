defmodule Tqm.Repo.Migrations.RenameJobDescription do
  use Ecto.Migration

  def change do
    rename table(:jobs), :work_description, to: :description
  end
end
