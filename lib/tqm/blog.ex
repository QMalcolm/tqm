defmodule Tqm.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Tqm.Repo

  alias Tqm.Accounts.Person
  alias Tqm.Blog.BlogPost

  #  Returns an unpaginated list of published blog_posts
  #
  # A blog post is "published" if its `published_at` value is not `nil`
  # and is in the past.
  defp list_published_blog_posts() do
    time_now = NaiveDateTime.utc_now()

    Repo.all(
      from bp in BlogPost, where: bp.published_at <= ^time_now and not is_nil(bp.published_at)
    )
  end

  @doc """
  Returns an unpaginated list of blog_posts.

  Optionally takes a `%Person{}` as a parameter. If the person is not an
  owner, only "published" blog posts will be returned. If the person is an
  owner, all blog posts will be returned.

  ## Examples

      iex> list_blog_posts()
      [%BlogPost{}, ...]

      iex> list_blog_posts(%Person{role: })
      [%BlogPost{}, ...]

      iex> list_blog_posts(%Person{role: owner})
      [%BlogPost{}, ...]

  """
  def list_blog_posts(), do: list_published_blog_posts()
  def list_blog_posts(nil), do: list_published_blog_posts()

  def list_blog_posts(%Person{} = person) do
    if Person.owner?(person) do
      Repo.all(BlogPost)
    else
      list_published_blog_posts()
    end
  end

  @doc """
  Gets a single blog_post.

  Raises `Ecto.NoResultsError` if the Blog post does not exist.

  ## Examples

      iex> get_blog_post!(123)
      %BlogPost{}

      iex> get_blog_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_blog_post!(id), do: Repo.get!(BlogPost, id)

  @doc """
  Creates a blog_post.

  ## Examples

      iex> create_blog_post(%{field: value})
      {:ok, %BlogPost{}}

      iex> create_blog_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_blog_post(attrs \\ %{}) do
    %BlogPost{}
    |> BlogPost.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a blog_post.

  ## Examples

      iex> update_blog_post(blog_post, %{field: new_value})
      {:ok, %BlogPost{}}

      iex> update_blog_post(blog_post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_blog_post(%BlogPost{} = blog_post, attrs) do
    blog_post
    |> BlogPost.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a blog_post.

  ## Examples

      iex> delete_blog_post(blog_post)
      {:ok, %BlogPost{}}

      iex> delete_blog_post(blog_post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_blog_post(%BlogPost{} = blog_post) do
    Repo.delete(blog_post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking blog_post changes.

  ## Examples

      iex> change_blog_post(blog_post)
      %Ecto.Changeset{data: %BlogPost{}}

  """
  def change_blog_post(%BlogPost{} = blog_post, attrs \\ %{}) do
    BlogPost.changeset(blog_post, attrs)
  end
end
