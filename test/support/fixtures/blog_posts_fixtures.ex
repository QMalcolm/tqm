defmodule Tqm.BlogPostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tqm.BlogPosts` context.
  """

  @doc """
  Generate a blog_post.
  """
  def blog_post_fixture(attrs \\ %{}) do
    {:ok, blog_post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        published_at: ~U[2021-11-25 19:50:00Z],
        title: "some title"
      })
      |> Tqm.BlogPosts.create_blog_post()

    blog_post
  end
end
