defmodule Tqm2.Repo.Migrations.CreateBlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts) do
      add :title, :string, nullable: false
      add :content, :text
      add :published_at, :utc_datetime, :null

      timestamps()
    end
  end
end
