defmodule TqmWeb.BlogPostLiveTest do
  use TqmWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tqm.BlogPostsFixtures

  @create_attrs %{content: "some content", published_at: %{day: 25, hour: 19, minute: 50, month: 11, year: 2021}, title: "some title"}
  @update_attrs %{content: "some updated content", published_at: %{day: 26, hour: 19, minute: 50, month: 11, year: 2021}, title: "some updated title"}
  @invalid_attrs %{content: nil, published_at: %{day: 30, hour: 19, minute: 50, month: 2, year: 2021}, title: nil}

  defp create_blog_post(_) do
    blog_post = blog_post_fixture()
    %{blog_post: blog_post}
  end

  describe "Index" do
    setup [:create_blog_post]

    test "lists all blog_post", %{conn: conn, blog_post: blog_post} do
      {:ok, _index_live, html} = live(conn, Routes.blog_post_index_path(conn, :index))

      assert html =~ "Listing Blog post"
      assert html =~ blog_post.content
    end

    test "saves new blog_post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.blog_post_index_path(conn, :index))

      assert index_live |> element("a", "New Blog post") |> render_click() =~
               "New Blog post"

      assert_patch(index_live, Routes.blog_post_index_path(conn, :new))

      assert index_live
             |> form("#blog_post-form", blog_post: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#blog_post-form", blog_post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.blog_post_index_path(conn, :index))

      assert html =~ "Blog post created successfully"
      assert html =~ "some content"
    end

    test "updates blog_post in listing", %{conn: conn, blog_post: blog_post} do
      {:ok, index_live, _html} = live(conn, Routes.blog_post_index_path(conn, :index))

      assert index_live |> element("#blog_post-#{blog_post.id} a", "Edit") |> render_click() =~
               "Edit Blog post"

      assert_patch(index_live, Routes.blog_post_index_path(conn, :edit, blog_post))

      assert index_live
             |> form("#blog_post-form", blog_post: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#blog_post-form", blog_post: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.blog_post_index_path(conn, :index))

      assert html =~ "Blog post updated successfully"
      assert html =~ "some updated content"
    end

    test "deletes blog_post in listing", %{conn: conn, blog_post: blog_post} do
      {:ok, index_live, _html} = live(conn, Routes.blog_post_index_path(conn, :index))

      assert index_live |> element("#blog_post-#{blog_post.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#blog_post-#{blog_post.id}")
    end
  end

  describe "Show" do
    setup [:create_blog_post]

    test "displays blog_post", %{conn: conn, blog_post: blog_post} do
      {:ok, _show_live, html} = live(conn, Routes.blog_post_show_path(conn, :show, blog_post))

      assert html =~ "Show Blog post"
      assert html =~ blog_post.content
    end

    test "updates blog_post within modal", %{conn: conn, blog_post: blog_post} do
      {:ok, show_live, _html} = live(conn, Routes.blog_post_show_path(conn, :show, blog_post))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Blog post"

      assert_patch(show_live, Routes.blog_post_show_path(conn, :edit, blog_post))

      assert show_live
             |> form("#blog_post-form", blog_post: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#blog_post-form", blog_post: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.blog_post_show_path(conn, :show, blog_post))

      assert html =~ "Blog post updated successfully"
      assert html =~ "some updated content"
    end
  end
end
