defmodule TqmWeb.BlogPostLive.Form do
  use TqmWeb, :live_view

  alias Tqm.Blog
  alias Tqm.Blog.BlogPost

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, mode: :write, tlp: :blog, scheduling: false, publish_status: :draft)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    blog_post = Blog.get_blog_post!(:all, id)
    changeset = Blog.change_blog_post(blog_post)

    {:noreply,
     assign(socket,
       blog_post: blog_post,
       changeset: changeset,
       publish_status: publish_status(blog_post),
       page_title: "Edit post"
     )}
  end

  def handle_params(_params, _url, socket) do
    changeset = Blog.change_blog_post(%BlogPost{})

    {:noreply,
     assign(socket, blog_post: %BlogPost{}, changeset: changeset, page_title: "New post")}
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

  def handle_event("publish_now", _params, socket) do
    attrs = current_attrs(socket.assigns.changeset) |> Map.put(:published_at, DateTime.utc_now())

    case Blog.update_blog_post(socket.assigns.blog_post, attrs) do
      {:ok, blog_post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Blog post published.")
         |> push_navigate(to: ~p"/blog/#{blog_post}")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("show_schedule_form", _params, socket) do
    {:noreply, assign(socket, scheduling: true)}
  end

  def handle_event("hide_schedule_form", _params, socket) do
    {:noreply, assign(socket, scheduling: false)}
  end

  def handle_event("schedule", %{"scheduled_at" => scheduled_at_str}, socket) do
    case NaiveDateTime.from_iso8601(scheduled_at_str <> ":00") do
      {:ok, naive_dt} ->
        {:ok, utc_dt} = DateTime.from_naive(naive_dt, "Etc/UTC")
        attrs = current_attrs(socket.assigns.changeset) |> Map.put(:published_at, utc_dt)

        case Blog.update_blog_post(socket.assigns.blog_post, attrs) do
          {:ok, blog_post} ->
            {:noreply,
             socket
             |> put_flash(:info, "Blog post scheduled.")
             |> push_navigate(to: ~p"/blog/#{blog_post}")}

          {:error, changeset} ->
            {:noreply, assign(socket, changeset: changeset)}
        end

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Invalid date/time.")}
    end
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

  defp current_attrs(changeset) do
    current = Ecto.Changeset.apply_changes(changeset)
    %{title: current.title, content: current.content}
  end

  defp publish_status(%{published_at: nil}), do: :draft

  defp publish_status(%{published_at: published_at}) do
    if DateTime.compare(published_at, DateTime.utc_now()) == :gt, do: :scheduled, else: :published
  end
end
