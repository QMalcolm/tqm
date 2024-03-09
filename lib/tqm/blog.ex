defmodule Tqm.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Tqm.Repo

  alias Tqm.Accounts.Person
  alias Tqm.Blog.BlogPost

  @doc """
  Returns an atom denoting blog_post viewing permissions a person has.

  Possible return values: `:published`, `:all`

  ## Examples
    iex> viewing_permissions_for_person()
    :published

    iex> viewing_permissions_for_person(nil)
    :published

    iex> viewing_permissions_for_person(%Person{role: :stranger})
    :published

    iex> viewing_permissions_for_person(%Person{role: :owner})
    :all
  """
  def viewing_permissions_for_person(), do: :published
  def viewing_permissions_for_person(nil), do: :published

  def viewing_permissions_for_person(%Person{} = person) do
    if Person.owner?(person) do
      :all
    else
      :published
    end
  end

  @doc """
  Returns an unpaginated list of blog_posts.

  Optionally an atom: `:published` and `:all`. The default value is
  `:published`, which will only return blog_posts that have a `published_at`
  value that is in the past. Passing `:all` will return all blog_posts which
  includes published blog_posts as well as blog_posts with a `published_at`
  of `nil` or a future date.

  ## Examples

      iex> list_blog_posts()
      [%BlogPost{}, ...]

      iex> list_blog_posts(:published)
      [%BlogPost{}, ...]

      iex> list_blog_posts(:all)
      [%BlogPost{}, %BlogPost{published_at: nil}, ...]

  """
  def list_blog_posts(), do: list_blog_posts(:published)

  def list_blog_posts(:published) do
    time_now = NaiveDateTime.utc_now()

    Repo.all(
      from bp in BlogPost, where: bp.published_at <= ^time_now and not is_nil(bp.published_at)
    )
  end

  def list_blog_posts(:all), do: Repo.all(BlogPost)

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
