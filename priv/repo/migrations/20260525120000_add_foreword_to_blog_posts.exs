defmodule Tqm.Repo.Migrations.AddForewordToBlogPosts do
  use Ecto.Migration

  def change do
    alter table(:blog_posts) do
      add :foreword, :text
    end
  end
end
