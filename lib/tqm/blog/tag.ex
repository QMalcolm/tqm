defmodule Tqm.Blog.Tag do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :slug, :string

    many_to_many :blog_posts, Tqm.Blog.BlogPost, join_through: "blog_post_tags"

    timestamps()
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[a-zA-Z0-9][a-zA-Z0-9 -]*$/,
      message: "only letters, numbers, spaces, and hyphens allowed"
    )
    |> validate_length(:name, max: 50)
    |> put_slug()
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end

  @doc """
  Derives a URL-safe slug from a tag name.

  Lowercases, replaces whitespace runs with a single hyphen, and strips
  any characters that are not alphanumeric or hyphens.

  ## Examples

      iex> Tqm.Blog.Tag.slugify("Elixir")
      "elixir"

      iex> Tqm.Blog.Tag.slugify("Machine Learning")
      "machine-learning"

      iex> Tqm.Blog.Tag.slugify("C++")
      "c"

  """
  def slugify(name) do
    name
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/[^a-z0-9-]/, "")
    |> String.trim("-")
  end

  defp put_slug(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name -> put_change(changeset, :slug, slugify(name))
    end
  end
end
