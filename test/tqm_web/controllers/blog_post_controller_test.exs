defmodule TqmWeb.BlogPostControllerTest do
  use TqmWeb.ConnCase

  import Tqm.BlogFixtures

  @create_attrs %{
    content: "some content",
    published_at: ~U[2023-01-28 02:26:00Z],
    title: "some title"
  }
  @update_attrs %{
    content: "some updated content",
    published_at: ~U[2023-01-29 02:26:00Z],
    title: "some updated title"
  }
  @invalid_attrs %{content: nil, published_at: nil, title: nil}

  describe "index" do
    test "lists all blog_posts", %{conn: conn} do
      conn = get(conn, ~p"/blog")
      assert html_response(conn, 200) =~ "Listing Blog posts"
    end
  end

  describe "new blog_post" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/blog/new")
      assert html_response(conn, 200) =~ "New Blog post"
    end
  end

  describe "create blog_post" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/blog", blog_post: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/blog/#{id}"

      conn = get(conn, ~p"/blog/#{id}")
      assert html_response(conn, 200) =~ "Blog post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/blog", blog_post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Blog post"
    end
  end

  describe "edit blog_post" do
    setup [:create_blog_post]

    test "renders form for editing chosen blog_post", %{conn: conn, blog_post: blog_post} do
      conn = get(conn, ~p"/blog/#{blog_post}/edit")
      assert html_response(conn, 200) =~ "Edit Blog post"
    end
  end

  describe "update blog_post" do
    setup [:create_blog_post]

    test "redirects when data is valid", %{conn: conn, blog_post: blog_post} do
      conn = put(conn, ~p"/blog/#{blog_post}", blog_post: @update_attrs)
      assert redirected_to(conn) == ~p"/blog/#{blog_post}"

      conn = get(conn, ~p"/blog/#{blog_post}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, blog_post: blog_post} do
      conn = put(conn, ~p"/blog/#{blog_post}", blog_post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Blog post"
    end
  end

  describe "delete blog_post" do
    setup [:create_blog_post]

    test "deletes chosen blog_post", %{conn: conn, blog_post: blog_post} do
      conn = delete(conn, ~p"/blog/#{blog_post}")
      assert redirected_to(conn) == ~p"/blog"

      assert_error_sent 404, fn ->
        get(conn, ~p"/blog/#{blog_post}")
      end
    end
  end

  defp create_blog_post(_) do
    blog_post = blog_post_fixture()
    %{blog_post: blog_post}
  end
end
