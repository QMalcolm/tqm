defmodule Tqm.Repo.Migrations.AddSlugToBlogPosts do
  use Ecto.Migration

  import Ecto.Query

  def up do
    alter table(:blog_posts) do
      add :slug, :string
    end

    flush()

    backfill_slugs()

    execute "ALTER TABLE blog_posts ALTER COLUMN slug SET NOT NULL"

    create unique_index(:blog_posts, [:slug])
  end

  def down do
    drop unique_index(:blog_posts, [:slug])

    alter table(:blog_posts) do
      remove :slug
    end
  end

  defp backfill_slugs do
    posts = repo().all(from(p in "blog_posts", select: {p.id, p.title}))

    Enum.reduce(posts, MapSet.new(), fn {id, title}, seen ->
      base =
        case slugify(title) do
          "" -> "post-#{id}"
          s -> s
        end

      slug = if MapSet.member?(seen, base), do: "#{base}-#{id}", else: base

      repo().update_all(from(p in "blog_posts", where: p.id == ^id), set: [slug: slug])
      MapSet.put(seen, slug)
    end)
  end

  defp slugify(name) do
    name
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/[^a-z0-9-]/, "")
    |> String.trim("-")
  end
end
