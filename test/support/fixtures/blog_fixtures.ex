defmodule Tqm.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tqm.Blog` context.
  """

  @doc """
  Generate a published blog_post.
  """
  def blog_post_fixture(attrs \\ %{}) do
    {:ok, blog_post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        published_at: ~U[2023-01-28 02:26:00Z],
        title: "some title 1"
      })
      |> Tqm.Blog.create_blog_post()

    blog_post
  end

  @doc """
  Generate an unpublished blog_post.
  """
  def unpublished_blog_post_fixture(attrs \\ %{}) do
    {:ok, blog_post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        published_at: nil,
        title: "some title 2"
      })
      |> Tqm.Blog.create_blog_post()

    blog_post
  end

  @doc """
  Generate a future published blog_post.
  """
  def future_blog_post_fixture(attrs \\ %{}) do
    {:ok, blog_post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        published_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 1, :day),
        title: "some title 3"
      })
      |> Tqm.Blog.create_blog_post()

    blog_post
  end
end
