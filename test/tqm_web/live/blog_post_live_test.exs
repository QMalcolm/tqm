defmodule TqmWeb.BlogPostLive.FormTest do
  use TqmWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tqm.AccountsFixtures
  import Tqm.BlogFixtures

  describe "new post" do
    test "renders form", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_person(owner_person_fixture())
        |> live(~p"/blog/new")

      assert html =~ "New post"
    end

    test "redirects to homepage for non owners", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/blog/new")

      assert {:error, {:redirect, %{to: "/"}}} =
               conn
               |> log_in_person(stranger_person_fixture())
               |> live(~p"/blog/new")

      assert {:error, {:redirect, %{to: "/"}}} =
               conn
               |> log_in_person(non_stranger_person_fixture())
               |> live(~p"/blog/new")
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      owner_conn = conn |> log_in_person(owner_person_fixture())
      {:ok, lv, _html} = live(owner_conn, ~p"/blog/new")

      assert {:error, {:live_redirect, %{to: path}}} =
               lv
               |> form("#blog_post_form", blog_post: %{title: "My title", content: "My content"})
               |> render_submit()

      assert path =~ ~p"/blog/"
      assert html_response(get(owner_conn, path), 200) =~ "My title"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, lv, _html} =
        conn
        |> log_in_person(owner_person_fixture())
        |> live(~p"/blog/new")

      result =
        lv
        |> form("#blog_post_form", blog_post: %{title: "", content: ""})
        |> render_submit()

      assert result =~ "Oops, something went wrong!"
    end
  end

  describe "edit post" do
    test "renders form for editing chosen post", %{conn: conn} do
      blog_post = blog_post_fixture()

      {:ok, _lv, html} =
        conn
        |> log_in_person(owner_person_fixture())
        |> live(~p"/blog/#{blog_post}/edit")

      assert html =~ "Edit post"
      assert html =~ blog_post.title
    end

    test "redirects to homepage for non owners", %{conn: conn} do
      blog_post = blog_post_fixture()

      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/blog/#{blog_post}/edit")

      assert {:error, {:redirect, %{to: "/"}}} =
               conn
               |> log_in_person(stranger_person_fixture())
               |> live(~p"/blog/#{blog_post}/edit")

      assert {:error, {:redirect, %{to: "/"}}} =
               conn
               |> log_in_person(non_stranger_person_fixture())
               |> live(~p"/blog/#{blog_post}/edit")
    end
  end

  describe "update post" do
    test "redirects to show when data is valid", %{conn: conn} do
      blog_post = blog_post_fixture()
      owner_conn = conn |> log_in_person(owner_person_fixture())
      {:ok, lv, _html} = live(owner_conn, ~p"/blog/#{blog_post}/edit")

      assert {:error, {:live_redirect, %{to: path}}} =
               lv
               |> form("#blog_post_form", blog_post: %{title: "Updated title"})
               |> render_submit()

      assert path == ~p"/blog/#{blog_post}"
      assert html_response(get(owner_conn, path), 200) =~ "Updated title"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      blog_post = blog_post_fixture()

      {:ok, lv, _html} =
        conn
        |> log_in_person(owner_person_fixture())
        |> live(~p"/blog/#{blog_post}/edit")

      result =
        lv
        |> form("#blog_post_form", blog_post: %{title: "", content: ""})
        |> render_submit()

      assert result =~ "Oops, something went wrong!"
    end
  end

  describe "write/preview mode" do
    test "toggles between write and preview", %{conn: conn} do
      {:ok, lv, _html} =
        conn
        |> log_in_person(owner_person_fixture())
        |> live(~p"/blog/new")

      html = lv |> element("button", "Preview") |> render_click()
      assert html =~ "Untitled"

      html = lv |> element("button", "Write") |> render_click()
      assert html =~ "Title"
    end

    test "preview reflects live changeset content", %{conn: conn} do
      {:ok, lv, _html} =
        conn
        |> log_in_person(owner_person_fixture())
        |> live(~p"/blog/new")

      lv
      |> form("#blog_post_form", blog_post: %{title: "Preview title", content: "Preview content"})
      |> render_change()

      html = lv |> element("button", "Preview") |> render_click()
      assert html =~ "Preview title"
      assert html =~ "Preview content"
    end
  end

  describe "publish controls" do
    test "publish now publishes a draft post and redirects to show", %{conn: conn} do
      blog_post = unpublished_blog_post_fixture()
      owner_conn = conn |> log_in_person(owner_person_fixture())
      {:ok, lv, html} = live(owner_conn, ~p"/blog/#{blog_post}/edit")

      assert html =~ "Publish now"

      assert {:error, {:live_redirect, %{to: path}}} =
               lv |> element("button[phx-click='publish_now']") |> render_click()

      assert path == ~p"/blog/#{blog_post}"
    end

    test "schedule form shows and hides", %{conn: conn} do
      blog_post = unpublished_blog_post_fixture()

      {:ok, lv, _html} =
        conn
        |> log_in_person(owner_person_fixture())
        |> live(~p"/blog/#{blog_post}/edit")

      lv |> element("button[phx-click='show_schedule_form']") |> render_click()
      assert lv |> element("form[phx-submit='schedule']") |> has_element?()

      lv |> element("button[phx-click='hide_schedule_form']") |> render_click()
      refute lv |> element("form[phx-submit='schedule']") |> has_element?()
    end

    test "publish controls not shown for already published posts", %{conn: conn} do
      blog_post = blog_post_fixture()

      {:ok, _lv, html} =
        conn
        |> log_in_person(owner_person_fixture())
        |> live(~p"/blog/#{blog_post}/edit")

      refute html =~ "Publish now"
      refute html =~ "Schedule publishing"
    end
  end
end
