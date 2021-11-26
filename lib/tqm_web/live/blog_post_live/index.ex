defmodule TqmWeb.BlogPostLive.Index do
  use TqmWeb, :live_view

  alias Tqm.BlogPosts
  alias Tqm.BlogPosts.BlogPost

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :blog_post_collection, list_blog_post())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Blog post")
    |> assign(:blog_post, BlogPosts.get_blog_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Blog post")
    |> assign(:blog_post, %BlogPost{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Blog post")
    |> assign(:blog_post, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    blog_post = BlogPosts.get_blog_post!(id)
    {:ok, _} = BlogPosts.delete_blog_post(blog_post)

    {:noreply, assign(socket, :blog_post_collection, list_blog_post())}
  end

  defp list_blog_post do
    BlogPosts.list_blog_post()
  end
end
