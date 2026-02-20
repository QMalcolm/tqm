defmodule TqmWeb.BlogPostControllerTest do
  use TqmWeb.ConnCase

  import Tqm.AccountsFixtures
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

  describe "new blog_post" do
    test "renders form", %{conn: conn} do
      conn =
        conn
        |> log_in_person(owner_person_fixture())
        |> get(~p"/blog/new")

      assert html_response(conn, 200) =~ "New Blog post"
    end

    test "redirects to homepage for non owners", %{conn: conn} do
      un_authed_conn =
        conn
        |> get(~p"/blog/new")

      assert redirected_to(un_authed_conn) =~ ~p"/"

      stranger_conn =
        conn
        |> log_in_person(stranger_person_fixture())
        |> get(~p"/blog/new")

      assert redirected_to(stranger_conn) =~ ~p"/"

      non_stranger_conn =
        conn
        |> log_in_person(non_stranger_person_fixture())
        |> get(~p"/blog/new")

      assert redirected_to(non_stranger_conn) =~ ~p"/"
    end
  end

  describe "create blog_post" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        conn
        |> log_in_person(owner_person_fixture())
        |> post(~p"/blog", blog_post: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/blog/#{id}"

      conn = get(conn, ~p"/blog/#{id}")
      assert html_response(conn, 200) =~ @create_attrs.title
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> log_in_person(owner_person_fixture())
        |> post(~p"/blog", blog_post: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Blog post"
    end

    test "redirects to homepage for non owners", %{conn: conn} do
      un_authed_conn =
        conn
        |> post(~p"/blog", blog_post: @create_attrs)

      assert redirected_to(un_authed_conn) =~ ~p"/"

      stranger_conn =
        conn
        |> log_in_person(stranger_person_fixture())
        |> post(~p"/blog", blog_post: @create_attrs)

      assert redirected_to(stranger_conn) =~ ~p"/"

      non_stranger_conn =
        conn
        |> log_in_person(non_stranger_person_fixture())
        |> post(~p"/blog", blog_post: @create_attrs)

      assert redirected_to(non_stranger_conn) =~ ~p"/"
    end
  end

  describe "edit blog_post" do
    setup [:create_blog_post]

    test "renders form for editing chosen blog_post", %{conn: conn, blog_post: blog_post} do
      conn =
        conn
        |> log_in_person(owner_person_fixture())
        |> get(~p"/blog/#{blog_post}/edit")

      assert html_response(conn, 200) =~ "Edit Blog post"
    end

    test "redirects to homepage for non owners", %{conn: conn, blog_post: blog_post} do
      un_authed_conn =
        conn
        |> get(~p"/blog/#{blog_post}/edit")

      assert redirected_to(un_authed_conn) =~ ~p"/"

      stranger_conn =
        conn
        |> log_in_person(stranger_person_fixture())
        |> get(~p"/blog/#{blog_post}/edit")

      assert redirected_to(stranger_conn) =~ ~p"/"

      non_stranger_conn =
        conn
        |> log_in_person(non_stranger_person_fixture())
        |> get(~p"/blog/#{blog_post}/edit")

      assert redirected_to(non_stranger_conn) =~ ~p"/"
    end
  end

  describe "update blog_post" do
    setup [:create_blog_post]

    test "redirects when data is valid", %{conn: conn, blog_post: blog_post} do
      conn =
        conn
        |> log_in_person(owner_person_fixture())
        |> put(~p"/blog/#{blog_post}", blog_post: @update_attrs)

      assert redirected_to(conn) == ~p"/blog/#{blog_post}"

      conn = get(conn, ~p"/blog/#{blog_post}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, blog_post: blog_post} do
      conn =
        conn
        |> log_in_person(owner_person_fixture())
        |> put(~p"/blog/#{blog_post}", blog_post: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Blog post"
    end

    test "redirects to homepage for non owners", %{conn: conn, blog_post: blog_post} do
      un_authed_conn =
        conn
        |> put(~p"/blog/#{blog_post}", blog_post: @update_attrs)

      assert redirected_to(un_authed_conn) =~ ~p"/"

      stranger_conn =
        conn
        |> log_in_person(stranger_person_fixture())
        |> put(~p"/blog/#{blog_post}", blog_post: @update_attrs)

      assert redirected_to(stranger_conn) =~ ~p"/"

      non_stranger_conn =
        conn
        |> log_in_person(non_stranger_person_fixture())
        |> put(~p"/blog/#{blog_post}", blog_post: @update_attrs)

      assert redirected_to(non_stranger_conn) =~ ~p"/"
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
