defmodule Tqm.Repo.Migrations.CreateBlogPost do
  use Ecto.Migration

  def change do
    create table(:blog_post) do
      add :title, :string
      add :content, :string
      add :published_at, :utc_datetime

      timestamps()
    end
  end
end
