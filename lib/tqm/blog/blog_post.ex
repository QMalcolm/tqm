defmodule Tqm.Blog.BlogPost do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_posts" do
    field :content, :string
    field :published_at, :utc_datetime
    field :title, :string
    field :tag_names, :string, virtual: true

    many_to_many :tags, Tqm.Blog.Tag, join_through: "blog_post_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(blog_post, attrs) do
    blog_post
    |> cast(attrs, [:title, :content, :published_at, :tag_names])
    |> validate_required([:title, :content])
  end
end
