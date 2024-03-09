defmodule Tqm.Blog.BlogPost do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_posts" do
    field :content, :string
    field :published_at, :utc_datetime
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(blog_post, attrs) do
    blog_post
    |> cast(attrs, [:title, :content, :published_at])
    |> validate_required([:title, :content])
  end
end
