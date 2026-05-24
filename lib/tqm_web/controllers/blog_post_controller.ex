defmodule TqmWeb.BlogPostController do
  use TqmWeb, :controller

  alias Tqm.Blog

  def index(conn, params) do
    visibility = conn.assigns[:current_person] |> Blog.viewing_permissions_for_person()
    status_filter = Map.get(params, "status", "all")
    search_query = Map.get(params, "q", "")

    blog_posts =
      visibility
      |> Blog.list_blog_posts()
      |> filter_by_status(status_filter, visibility)
      |> filter_by_search(search_query)

    render(conn, :index,
      tlp: :blog,
      blog_posts: blog_posts,
      page_title: "Writing",
      current_tag: nil,
      status_filter: status_filter,
      search_query: search_query
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
      current_tag: current_tag,
      status_filter: "all",
      search_query: ""
    )
  end

  def show(conn, %{"slug" => slug}) do
    blog_post =
      conn.assigns[:current_person]
      |> Blog.viewing_permissions_for_person()
      |> Blog.get_blog_post!(slug)

    render(conn, :show, blog_post: blog_post, tlp: :blog, page_title: blog_post.title)
  end

  def delete(conn, %{"slug" => slug}) do
    blog_post = Blog.get_blog_post!(slug)
    {:ok, _blog_post} = Blog.delete_blog_post(blog_post)

    conn
    |> put_flash(:info, "Blog post deleted successfully.")
    |> redirect(to: ~p"/blog")
  end

  defp filter_by_status(posts, "published", _),
    do:
      Enum.filter(
        posts,
        &(&1.published_at != nil and DateTime.compare(&1.published_at, DateTime.utc_now()) != :gt)
      )

  defp filter_by_status(posts, "drafts", :all), do: Enum.filter(posts, &is_nil(&1.published_at))
  defp filter_by_status(posts, _, _), do: posts

  defp filter_by_search(posts, ""), do: posts

  defp filter_by_search(posts, query) do
    q = String.downcase(query)

    Enum.filter(posts, fn post ->
      String.contains?(String.downcase(post.title), q) or
        String.contains?(String.downcase(post.content || ""), q) or
        Enum.any?(post.tags, &String.contains?(String.downcase(&1.name), q))
    end)
  end
end
