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

    test "get_blog_post!/1 returns only published blog_posts" do
      published_blog_post = blog_post_fixture()
      unpublished_blog_post = unpublished_blog_post_fixture()
      future_blog_post = future_blog_post_fixture()

      assert Blog.get_blog_post!(published_blog_post.id) == published_blog_post
      assert_raise Ecto.NoResultsError, fn -> Blog.get_blog_post!(unpublished_blog_post.id) end
      assert_raise Ecto.NoResultsError, fn -> Blog.get_blog_post!(future_blog_post.id) end
    end

    test "get_blog_post!/2 returns based on permissions" do
      published_blog_post = blog_post_fixture()
      unpublished_blog_post = unpublished_blog_post_fixture()
      future_blog_post = future_blog_post_fixture()

      assert Blog.get_blog_post!(:published, published_blog_post.id) == published_blog_post
      assert Blog.get_blog_post!(:all, published_blog_post.id) == published_blog_post

      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_blog_post!(:published, unpublished_blog_post.id)
      end

      assert Blog.get_blog_post!(:all, unpublished_blog_post.id) == unpublished_blog_post

      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_blog_post!(:published, future_blog_post.id)
      end

      assert Blog.get_blog_post!(:all, future_blog_post.id) == future_blog_post
    end

    test "create_blog_post/1 with valid data creates a blog_post" do
      assert {:ok, %BlogPost{} = blog_post} = Blog.create_blog_post(@published_valid_attrs)
      assert blog_post.content == @published_valid_attrs.content
      assert blog_post.published_at == @published_valid_attrs.published_at
      assert blog_post.title == @published_valid_attrs.title

      assert {:ok, %BlogPost{} = blog_post} = Blog.create_blog_post(@unpublished_valid_attrs)
      assert blog_post.content == @unpublished_valid_attrs.content
      assert blog_post.published_at == @unpublished_valid_attrs.published_at
      assert blog_post.title == @unpublished_valid_attrs.title
    end

    test "create_blog_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_blog_post(@invalid_attrs)
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
      assert blog_post == Blog.get_blog_post!(blog_post.id)
    end

    test "delete_blog_post/1 deletes the blog_post" do
      blog_post = blog_post_fixture()
      assert {:ok, %BlogPost{}} = Blog.delete_blog_post(blog_post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_blog_post!(blog_post.id) end
    end

    test "change_blog_post/1 returns a blog_post changeset" do
      blog_post = blog_post_fixture()
      assert %Ecto.Changeset{} = Blog.change_blog_post(blog_post)
    end
  end
end
