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
  end
end
