defmodule TqmWeb.BlogPostControllerTest do
  use TqmWeb.ConnCase

  import Tqm.AccountsFixtures
  import Tqm.BlogFixtures

  @create_attrs %{
    content: "some content",
    published_at: ~U[2023-01-28 02:26:00Z],
    title: "some title"
  }

  describe "index" do
    test "lists all blog_posts", %{conn: conn} do
      conn = get(conn, ~p"/blog")
      assert html_response(conn, 200) =~ "Blog"
    end
  end

  describe "show" do
    test "show a blog_post", %{conn: conn} do
      blog_post = blog_post_fixture()
      conn = get(conn, ~p"/blog/#{blog_post.id}")
      assert html_response(conn, 200) =~ blog_post.content
    end

    test "show unpublished blog_post for owner person", %{conn: conn} do
      unpublished_blog_post = unpublished_blog_post_fixture()

      conn =
        conn
        |> log_in_person(owner_person_fixture())
        |> get(~p"/blog/#{unpublished_blog_post.id}")

      assert html_response(conn, 200) =~ unpublished_blog_post.content
    end

    test "show 404 for unpublished blog_post for non owner", %{conn: conn} do
      unpublished_blog_post = unpublished_blog_post_fixture()
      assert_error_sent(404, fn -> get(conn, ~p"/blog/#{unpublished_blog_post.id}") end)
    end

    test "show 404 for non-existant blog_post", %{conn: conn} do
      assert_error_sent(404, fn -> get(conn, ~p"/blog/0") end)
    end
  end

  describe "delete blog_post" do
    setup [:create_blog_post]

    test "deletes chosen blog_post", %{conn: conn, blog_post: blog_post} do
      conn =
        conn
        |> log_in_person(owner_person_fixture())
        |> delete(~p"/blog/#{blog_post}")

      assert redirected_to(conn) == ~p"/blog"

      assert_error_sent 404, fn ->
        get(conn, ~p"/blog/#{blog_post}")
      end
    end

    test "redirects to homepage for non owners", %{conn: conn, blog_post: blog_post} do
      un_authed_conn =
        conn
        |> delete(~p"/blog/#{blog_post}")

      assert redirected_to(un_authed_conn) =~ ~p"/"

      stranger_conn =
        conn
        |> log_in_person(stranger_person_fixture())
        |> delete(~p"/blog/#{blog_post}")

      assert redirected_to(stranger_conn) =~ ~p"/"

      non_stranger_conn =
        conn
        |> log_in_person(non_stranger_person_fixture())
        |> delete(~p"/blog/#{blog_post}")

      assert redirected_to(non_stranger_conn) =~ ~p"/"
    end
  end

  defp create_blog_post(_) do
    blog_post = blog_post_fixture()
    %{blog_post: blog_post}
  end
end
