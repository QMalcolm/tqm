defmodule Tqm.BlogTest do
  use Tqm.DataCase

  alias Tqm.Blog

  describe "blog_posts" do
    alias Tqm.Blog.BlogPost

    import Tqm.BlogFixtures
    import Tqm.AccountsFixtures

    @published_valid_attrs %{
      content: "some content",
      published_at: ~U[2023-01-28 02:26:00Z],
      title: "some title"
    }
    @unpublished_valid_attrs %{
      content: "in progress",
      published_at: nil,
      title: "post I want to do"
    }
    @invalid_attrs %{content: nil, published_at: nil, title: nil}

    test "viewing_permissions_for_person/0 returns expected value" do
      assert Blog.viewing_permissions_for_person() == :published
    end

    test "viewing_permissions_for_person/1 returns expected value" do
      assert Blog.viewing_permissions_for_person(nil) == :published
      assert Blog.viewing_permissions_for_person(stranger_person_fixture()) == :published
      assert Blog.viewing_permissions_for_person(non_stranger_person_fixture()) == :published
      assert Blog.viewing_permissions_for_person(owner_person_fixture()) == :all
    end

    test "list_blog_posts/0 returns all published blog posts" do
      blog_post = blog_post_fixture()
      unpublished_blog_post_fixture()
      future_blog_post_fixture()
      assert Blog.list_blog_posts() == [blog_post]
    end

    test "list_blog_posts/1 returns blog posts dependent on passed atom" do
      blog_post = blog_post_fixture()
      unpublished_blog_post = unpublished_blog_post_fixture()
      future_blog_post = future_blog_post_fixture()

      assert Blog.list_blog_posts(:all) == [blog_post, unpublished_blog_post, future_blog_post]
      assert Blog.list_blog_posts(:published) == [blog_post]
    end

    test "list_blog_posts/2 filters by tag slug" do
      elixir_post = blog_post_fixture(%{tag_names: "Elixir", title: "elixir post"})
      _other_post = blog_post_fixture(%{tag_names: "gardening", title: "gardening post"})

      result = Blog.list_blog_posts(:published, tag: "elixir")
      assert length(result) == 1
      assert hd(result).id == elixir_post.id
    end

    test "list_blog_posts/2 returns empty list for unknown tag" do
      blog_post_fixture()
      assert Blog.list_blog_posts(:published, tag: "nonexistent") == []
    end

    test "get_blog_post!/1 returns only published blog_posts" do
      published_blog_post = blog_post_fixture()
      unpublished_blog_post = unpublished_blog_post_fixture()
      future_blog_post = future_blog_post_fixture()

      assert Blog.get_blog_post!(published_blog_post.slug) == published_blog_post
      assert_raise Ecto.NoResultsError, fn -> Blog.get_blog_post!(unpublished_blog_post.slug) end
      assert_raise Ecto.NoResultsError, fn -> Blog.get_blog_post!(future_blog_post.slug) end
    end

    test "get_blog_post!/2 returns based on permissions" do
      published_blog_post = blog_post_fixture()
      unpublished_blog_post = unpublished_blog_post_fixture()
      future_blog_post = future_blog_post_fixture()

      assert Blog.get_blog_post!(:published, published_blog_post.slug) == published_blog_post
      assert Blog.get_blog_post!(:all, published_blog_post.slug) == published_blog_post

      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_blog_post!(:published, unpublished_blog_post.slug)
      end

      assert Blog.get_blog_post!(:all, unpublished_blog_post.slug) == unpublished_blog_post

      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_blog_post!(:published, future_blog_post.slug)
      end

      assert Blog.get_blog_post!(:all, future_blog_post.slug) == future_blog_post
    end

    test "create_blog_post/1 with valid data creates a blog_post" do
      assert {:ok, %BlogPost{} = blog_post} = Blog.create_blog_post(@published_valid_attrs)
      assert blog_post.content == @published_valid_attrs.content
      assert blog_post.published_at == @published_valid_attrs.published_at
      assert blog_post.title == @published_valid_attrs.title
      assert blog_post.slug == "some-title"

      assert {:ok, %BlogPost{} = blog_post} = Blog.create_blog_post(@unpublished_valid_attrs)
      assert blog_post.content == @unpublished_valid_attrs.content
      assert blog_post.published_at == @unpublished_valid_attrs.published_at
      assert blog_post.title == @unpublished_valid_attrs.title
      assert blog_post.slug == "post-i-want-to-do"
    end

    test "create_blog_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_blog_post(@invalid_attrs)
    end

    test "create_blog_post/1 creates and associates tags" do
      assert {:ok, %BlogPost{} = post} =
               Blog.create_blog_post(
                 Map.put(@published_valid_attrs, :tag_names, "Elixir, Phoenix")
               )

      assert [%{name: "Elixir", slug: "elixir"}, %{name: "Phoenix", slug: "phoenix"}] =
               Enum.sort_by(post.tags, & &1.name)
    end

    test "create_blog_post/1 reuses existing tags" do
      Blog.get_or_create_tag("Elixir")

      assert {:ok, post} =
               Blog.create_blog_post(Map.put(@published_valid_attrs, :tag_names, "Elixir"))

      assert length(post.tags) == 1
      assert length(Blog.list_tags()) == 1
    end

    test "update_blog_post/2 with valid data updates the blog_post" do
      blog_post = blog_post_fixture()

      update_attrs = %{
        content: "some updated content",
        published_at: ~U[2023-01-29 02:26:00Z],
        title: "some updated title"
      }

      assert {:ok, %BlogPost{} = blog_post} = Blog.update_blog_post(blog_post, update_attrs)
      assert blog_post.content == "some updated content"
      assert blog_post.published_at == ~U[2023-01-29 02:26:00Z]
      assert blog_post.title == "some updated title"
    end

    test "update_blog_post/2 with invalid data returns error changeset" do
      blog_post = blog_post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_blog_post(blog_post, @invalid_attrs)
      assert blog_post == Blog.get_blog_post!(blog_post.slug)
    end

    test "update_blog_post/2 preserves slug when title changes" do
      blog_post = blog_post_fixture()
      assert {:ok, updated} = Blog.update_blog_post(blog_post, %{title: "Completely Different"})
      assert updated.slug == blog_post.slug
    end

    test "update_blog_post/2 replaces tags when tag_names provided" do
      post = blog_post_fixture(%{tag_names: "Elixir"})
      assert {:ok, updated} = Blog.update_blog_post(post, %{tag_names: "Phoenix"})
      assert [%{slug: "phoenix"}] = updated.tags
    end

    test "update_blog_post/2 preserves tags when tag_names absent" do
      post = blog_post_fixture(%{tag_names: "Elixir"})
      assert {:ok, updated} = Blog.update_blog_post(post, %{title: "New title"})
      assert [%{slug: "elixir"}] = updated.tags
    end

    test "delete_blog_post/1 deletes the blog_post" do
      blog_post = blog_post_fixture()
      assert {:ok, %BlogPost{}} = Blog.delete_blog_post(blog_post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_blog_post!(blog_post.slug) end
    end

    test "change_blog_post/1 returns a blog_post changeset" do
      blog_post = blog_post_fixture()
      assert %Ecto.Changeset{} = Blog.change_blog_post(blog_post)
    end

    test "change_blog_post/1 populates tag_names from loaded tags" do
      post = blog_post_fixture(%{tag_names: "Elixir, Phoenix"})
      changeset = Blog.change_blog_post(post)
      tag_names = Ecto.Changeset.get_field(changeset, :tag_names)
      assert tag_names =~ "Elixir"
      assert tag_names =~ "Phoenix"
    end
  end

  describe "tags" do
    alias Tqm.Blog.Tag

    test "get_or_create_tag/1 creates a new tag" do
      assert {:ok, %Tag{name: "Elixir", slug: "elixir"}} = Blog.get_or_create_tag("Elixir")
    end

    test "get_or_create_tag/1 returns existing tag on duplicate slug" do
      {:ok, tag} = Blog.get_or_create_tag("Elixir")
      assert {:ok, ^tag} = Blog.get_or_create_tag("Elixir")
      assert length(Blog.list_tags()) == 1
    end

    test "list_tags/0 returns tags sorted by name" do
      {:ok, _} = Blog.get_or_create_tag("Phoenix")
      {:ok, _} = Blog.get_or_create_tag("Elixir")
      names = Blog.list_tags() |> Enum.map(& &1.name)
      assert names == ["Elixir", "Phoenix"]
    end

    test "get_tag_by_slug/1 returns matching tag" do
      {:ok, tag} = Blog.get_or_create_tag("Elixir")
      assert Blog.get_tag_by_slug("elixir") == tag
    end

    test "get_tag_by_slug/1 returns nil for unknown slug" do
      assert Blog.get_tag_by_slug("nonexistent") == nil
    end

    test "Tag.slugify/1 normalizes names to URL-safe slugs" do
      assert Tag.slugify("Elixir") == "elixir"
      assert Tag.slugify("Machine Learning") == "machine-learning"
      assert Tag.slugify("C++") == "c"
    end
  end
end
