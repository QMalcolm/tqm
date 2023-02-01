defmodule Tqm.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tqm.Blog` context.
  """

  @doc """
  Generate a blog_post.
  """
  def blog_post_fixture(attrs \\ %{}) do
    {:ok, blog_post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        published_at: ~U[2023-01-28 02:26:00Z],
        title: "some title"
      })
      |> Tqm.Blog.create_blog_post()

    blog_post
  end
end
