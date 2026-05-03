defmodule Tqm.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Tqm.Repo

  alias Tqm.Accounts.Person
  alias Tqm.Blog.BlogPost
  alias Tqm.Blog.Tag

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
  Returns an unpaginated list of blog_posts with tags preloaded.

  Accepts a visibility atom (`:published` or `:all`) and an optional
  keyword list. Supported opts:

    * `:tag` — a tag slug string; when provided only posts tagged with
      that slug are returned.

  ## Examples

      iex> list_blog_posts()
      [%BlogPost{}, ...]

      iex> list_blog_posts(:published)
      [%BlogPost{}, ...]

      iex> list_blog_posts(:all)
      [%BlogPost{}, %BlogPost{published_at: nil}, ...]

      iex> list_blog_posts(:published, tag: "elixir")
      [%BlogPost{}, ...]

  """
  def list_blog_posts(visibility \\ :published, opts \\ [])

  def list_blog_posts(:published, opts) do
    time_now = NaiveDateTime.utc_now()
    tag_slug = Keyword.get(opts, :tag)

    base =
      from bp in BlogPost,
        where: bp.published_at <= ^time_now and not is_nil(bp.published_at)

    query =
      if tag_slug do
        from bp in base,
          join: t in assoc(bp, :tags),
          where: t.slug == ^tag_slug
      else
        base
      end

    Repo.all(from bp in query, preload: :tags)
  end

  def list_blog_posts(:all, _opts) do
    Repo.all(from bp in BlogPost, preload: :tags)
  end

  @doc """
  Gets a single blog_post with tags preloaded.

  Raises `Ecto.NoResultsError` if the Blog post does not exist.

  ## Examples

      iex> get_blog_post!(123)
      %BlogPost{}

      iex> get_blog_post!(456)
      ** (Ecto.NoResultsError)

      iex> get_blog_post!(:published, 111)
      ** (Ecto.NoResultsError)

      iex> get_blog_post!(:all, 111)
      %BlogPost{}

  """
  def get_blog_post!(id), do: get_blog_post!(:published, id)

  def get_blog_post!(:published, id) do
    time_now = NaiveDateTime.utc_now()

    Repo.one!(
      from bp in BlogPost,
        where: bp.id == ^id and bp.published_at <= ^time_now and not is_nil(bp.published_at)
    )
    |> Repo.preload(:tags)
  end

  def get_blog_post!(:all, id) do
    Repo.get!(BlogPost, id)
    |> Repo.preload(:tags)
  end

  @doc """
  Returns all tags sorted by name.
  """
  def list_tags do
    Repo.all(from t in Tag, order_by: t.name)
  end

  @doc """
  Returns the tag with the given slug, or nil if none exists.
  """
  def get_tag_by_slug(slug), do: Repo.get_by(Tag, slug: slug)

  @doc """
  Finds an existing tag by slug or creates a new one from the given name.
  """
  def get_or_create_tag(name) do
    slug = Tag.slugify(name)

    case Repo.get_by(Tag, slug: slug) do
      nil ->
        %Tag{}
        |> Tag.changeset(%{name: name})
        |> Repo.insert()

      tag ->
        {:ok, tag}
    end
  end

  @doc """
  Creates a blog_post.

  ## Examples

      iex> create_blog_post(%{field: value})
      {:ok, %BlogPost{}}

      iex> create_blog_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_blog_post(attrs \\ %{}) do
    tags = resolve_tags(attrs)

    %BlogPost{}
    |> BlogPost.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.insert()
  end

  @doc """
  Updates a blog_post.

  When `:tag_names` is present in `attrs` the post's tags are replaced with
  the resolved tag list. When `:tag_names` is absent the existing tags are
  left unchanged.

  ## Examples

      iex> update_blog_post(blog_post, %{field: new_value})
      {:ok, %BlogPost{}}

      iex> update_blog_post(blog_post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_blog_post(%BlogPost{} = blog_post, attrs) do
    blog_post = Repo.preload(blog_post, :tags)

    changeset = BlogPost.changeset(blog_post, attrs)

    changeset =
      case attrs[:tag_names] || attrs["tag_names"] do
        nil -> changeset
        _raw -> Ecto.Changeset.put_assoc(changeset, :tags, resolve_tags(attrs))
      end

    Repo.update(changeset)
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

  Populates the virtual `:tag_names` field from the loaded tags association
  when tags are preloaded, so the form reflects the current tag state.

  ## Examples

      iex> change_blog_post(blog_post)
      %Ecto.Changeset{data: %BlogPost{}}

  """
  def change_blog_post(%BlogPost{} = blog_post, attrs \\ %{}) do
    blog_post
    |> maybe_set_tag_names()
    |> BlogPost.changeset(attrs)
  end

  # Populates :tag_names from the loaded tags so form inputs reflect
  # the current state when editing. A no-op when tags are not loaded.
  defp maybe_set_tag_names(%BlogPost{tags: %Ecto.Association.NotLoaded{}} = post), do: post

  defp maybe_set_tag_names(%BlogPost{tags: tags} = post) do
    %{post | tag_names: Enum.map_join(tags, ", ", & &1.name)}
  end

  # Parses the tag_names string from attrs into a list of Tag structs,
  # finding or creating each tag. Returns [] when tag_names is absent.
  defp resolve_tags(attrs) do
    (attrs[:tag_names] || attrs["tag_names"] || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq_by(&Tag.slugify/1)
    |> Enum.map(fn name ->
      {:ok, tag} = get_or_create_tag(name)
      tag
    end)
  end
end
