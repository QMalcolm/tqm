defmodule TqmWeb.BlogPostLive.Form do
  use TqmWeb, :live_view

  alias Tqm.Blog
  alias Tqm.Blog.BlogPost

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, mode: :write, tlp: :blog)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    blog_post = Blog.get_blog_post!(:all, id)
    changeset = Blog.change_blog_post(blog_post)
    {:noreply, assign(socket, blog_post: blog_post, changeset: changeset)}
  end

  def handle_params(_params, _url, socket) do
    changeset = Blog.change_blog_post(%BlogPost{})
    {:noreply, assign(socket, blog_post: %BlogPost{}, changeset: changeset)}
  end

  @impl true
  def handle_event("set_mode", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, mode: String.to_existing_atom(mode))}
  end

  def handle_event("validate", %{"blog_post" => params}, socket) do
    changeset =
      socket.assigns.blog_post
      |> Blog.change_blog_post(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"blog_post" => params}, socket) do
    save_blog_post(socket, socket.assigns.live_action, params)
  end

  defp save_blog_post(socket, :new, params) do
    case Blog.create_blog_post(params) do
      {:ok, blog_post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Blog post created successfully.")
         |> push_navigate(to: ~p"/blog/#{blog_post}")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_blog_post(socket, :edit, params) do
    case Blog.update_blog_post(socket.assigns.blog_post, params) do
      {:ok, blog_post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Blog post updated successfully.")
         |> push_navigate(to: ~p"/blog/#{blog_post}")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
