defmodule TqmWeb.BlogPostLive.Show do
  use TqmWeb, :live_view

  alias Tqm.BlogPosts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:blog_post, BlogPosts.get_blog_post!(id))}
  end

  defp page_title(:show), do: "Show Blog post"
  defp page_title(:edit), do: "Edit Blog post"
end
