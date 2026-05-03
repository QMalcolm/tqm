defmodule TqmWeb.BlogPostController do
  use TqmWeb, :controller

  alias Tqm.Blog

  def index(conn, _params) do
    blog_posts =
      conn.assigns[:current_person]
      |> Blog.viewing_permissions_for_person()
      |> Blog.list_blog_posts()

    render(conn, :index,
      tlp: :blog,
      blog_posts: blog_posts,
      page_title: "Blog",
      current_tag: nil
    )
  end

  def tag(conn, %{"tag" => slug}) do
    visibility = conn.assigns[:current_person] |> Blog.viewing_permissions_for_person()
    blog_posts = Blog.list_blog_posts(visibility, tag: slug)
    current_tag = Blog.get_tag_by_slug(slug)

    render(conn, :index,
      tlp: :blog,
      blog_posts: blog_posts,
      page_title: if(current_tag, do: "#{current_tag.name} posts", else: "#{slug} posts"),
      current_tag: current_tag
    )
  end

  def show(conn, %{"id" => id}) do
    blog_post =
      conn.assigns[:current_person]
      |> Blog.viewing_permissions_for_person()
      |> Blog.get_blog_post!(id)

    render(conn, :show, blog_post: blog_post, tlp: :blog, page_title: blog_post.title)
  end

  def delete(conn, %{"id" => id}) do
    blog_post = Blog.get_blog_post!(id)
    {:ok, _blog_post} = Blog.delete_blog_post(blog_post)

    conn
    |> put_flash(:info, "Blog post deleted successfully.")
    |> redirect(to: ~p"/blog")
  end
end
