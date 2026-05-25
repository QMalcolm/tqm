defmodule Tqm.Blog.BlogPost do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_posts" do
    field :content, :string
    field :foreword, :string
    field :published_at, :utc_datetime
    field :title, :string
    field :slug, :string
    field :tag_names, :string, virtual: true

    many_to_many :tags, Tqm.Blog.Tag, join_through: "blog_post_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(blog_post, attrs) do
    blog_post
    |> cast(attrs, [:title, :content, :foreword, :published_at, :tag_names, :slug])
    |> validate_required([:title, :content])
    |> maybe_put_slug()
    |> validate_exclusion(:slug, ~w(new), message: "is reserved — choose a different title")
    |> unique_constraint(:slug)
  end

  @doc """
  Derives a URL-safe slug from a string.

  ## Examples

      iex> Tqm.Blog.BlogPost.slugify("My First Post")
      "my-first-post"

      iex> Tqm.Blog.BlogPost.slugify("Hello, World!")
      "hello-world"

      iex> Tqm.Blog.BlogPost.slugify("C++")
      "c"

  """
  def slugify(name) do
    name
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/[^a-z0-9-]/, "")
    |> String.trim("-")
  end

  defimpl Phoenix.Param do
    def to_param(%{slug: slug}) when is_binary(slug), do: slug
    def to_param(%{id: id}), do: to_string(id)
  end

  # Sets slug from title only when the post doesn't already have one.
  # Slug is immutable after creation so that published URLs don't change on title edits.
  defp maybe_put_slug(changeset) do
    case get_field(changeset, :slug) do
      nil ->
        case get_change(changeset, :title) do
          nil -> changeset
          title -> put_change(changeset, :slug, slugify(title))
        end

      _slug ->
        changeset
    end
  end
end
