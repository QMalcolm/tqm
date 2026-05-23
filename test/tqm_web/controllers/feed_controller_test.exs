defmodule TqmWeb.FeedControllerTest do
  use TqmWeb.ConnCase, async: true

  import Tqm.BlogFixtures

  describe "index" do
    test "returns an RSS feed with published posts", %{conn: conn} do
      blog_post = blog_post_fixture()
      conn = get(conn, ~p"/blog/feed.xml")

      assert response(conn, 200) =~ "<?xml"
      assert List.first(get_resp_header(conn, "content-type")) =~ "application/rss+xml"
      assert response(conn, 200) =~ blog_post.title
    end

    test "excludes unpublished posts", %{conn: conn} do
      unpublished = unpublished_blog_post_fixture()
      conn = get(conn, ~p"/blog/feed.xml")
      refute response(conn, 200) =~ unpublished.title
    end

    test "excludes future-scheduled posts", %{conn: conn} do
      future = future_blog_post_fixture()
      conn = get(conn, ~p"/blog/feed.xml")
      refute response(conn, 200) =~ future.title
    end

    test "includes category elements for tagged posts", %{conn: conn} do
      blog_post_fixture(%{tag_names: "Elixir"})
      conn = get(conn, ~p"/blog/feed.xml")
      assert response(conn, 200) =~ "<category>Elixir</category>"
    end
  end

  describe "tag" do
    test "returns an RSS feed filtered to the given tag", %{conn: conn} do
      tagged = blog_post_fixture(%{tag_names: "Elixir", title: "tagged post"})
      untagged = blog_post_fixture(%{title: "untagged post"})

      conn = get(conn, ~p"/blog/tags/elixir/feed.xml")

      body = response(conn, 200)
      assert body =~ "<?xml"
      assert List.first(get_resp_header(conn, "content-type")) =~ "application/rss+xml"
      assert body =~ tagged.title
      refute body =~ untagged.title
    end

    test "self-link points to the tag feed URL", %{conn: conn} do
      conn = get(conn, ~p"/blog/tags/elixir/feed.xml")
      assert response(conn, 200) =~ "/blog/tags/elixir/feed.xml"
    end

    test "returns empty feed for unknown tag", %{conn: conn} do
      blog_post_fixture()
      conn = get(conn, ~p"/blog/tags/nonexistent/feed.xml")
      body = response(conn, 200)
      assert body =~ "<?xml"
      refute body =~ "<item>"
    end

    test "excludes unpublished posts even for matching tag", %{conn: conn} do
      unpublished = unpublished_blog_post_fixture(%{tag_names: "Elixir"})
      conn = get(conn, ~p"/blog/tags/elixir/feed.xml")
      refute response(conn, 200) =~ unpublished.title
    end
  end
end
