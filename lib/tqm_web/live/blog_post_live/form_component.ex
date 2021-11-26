defmodule TqmWeb.BlogPostLive.FormComponent do
  use TqmWeb, :live_component

  alias Tqm.BlogPosts

  @impl true
  def update(%{blog_post: blog_post} = assigns, socket) do
    changeset = BlogPosts.change_blog_post(blog_post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"blog_post" => blog_post_params}, socket) do
    changeset =
      socket.assigns.blog_post
      |> BlogPosts.change_blog_post(blog_post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"blog_post" => blog_post_params}, socket) do
    save_blog_post(socket, socket.assigns.action, blog_post_params)
  end

  defp save_blog_post(socket, :edit, blog_post_params) do
    case BlogPosts.update_blog_post(socket.assigns.blog_post, blog_post_params) do
      {:ok, _blog_post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Blog post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_blog_post(socket, :new, blog_post_params) do
    case BlogPosts.create_blog_post(blog_post_params) do
      {:ok, _blog_post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Blog post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
