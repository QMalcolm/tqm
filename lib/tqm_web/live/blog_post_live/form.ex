defmodule TqmWeb.BlogPostLive.Form do
  use TqmWeb, :live_view

  alias Tqm.Blog
  alias Tqm.Blog.BlogPost

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       mode: :write,
       tlp: :blog,
       scheduling: false,
       publish_status: :draft,
       selected_tag_names: [],
       tag_search: "",
       tag_suggestions: [],
       tag_create_option: nil
     )}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _url, socket) do
    blog_post = Blog.get_blog_post!(:all, slug)
    changeset = Blog.change_blog_post(blog_post)

    {:noreply,
     assign(socket,
       blog_post: blog_post,
       changeset: changeset,
       selected_tag_names: Enum.map(blog_post.tags, & &1.name),
       publish_status: publish_status(blog_post),
       page_title: "Edit post"
     )}
  end

  def handle_params(_params, _url, socket) do
    changeset = Blog.change_blog_post(%BlogPost{})

    {:noreply,
     assign(socket,
       blog_post: %BlogPost{},
       changeset: changeset,
       page_title: "New post"
     )}
  end

  @impl true
  def handle_event("set_mode", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, mode: String.to_existing_atom(mode))}
  end

  def handle_event("validate", %{"blog_post" => params}, socket) do
    tag_names = Enum.join(socket.assigns.selected_tag_names, ", ")

    changeset =
      socket.assigns.blog_post
      |> Blog.change_blog_post(Map.put(params, "tag_names", tag_names))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"blog_post" => params}, socket) do
    tag_names = Enum.join(socket.assigns.selected_tag_names, ", ")
    save_blog_post(socket, socket.assigns.live_action, Map.put(params, "tag_names", tag_names))
  end

  def handle_event("search_tags", %{"value" => term}, socket) do
    term = String.trim(term)
    all_suggestions = Blog.search_tags(term)

    exact_match_exists =
      Enum.any?(all_suggestions, fn t ->
        String.downcase(t.name) == String.downcase(term)
      end)

    selected_lower = Enum.map(socket.assigns.selected_tag_names, &String.downcase/1)

    filtered =
      Enum.reject(all_suggestions, fn t ->
        String.downcase(t.name) in selected_lower
      end)

    create_option =
      if term != "" and not exact_match_exists, do: term, else: nil

    {:noreply,
     assign(socket,
       tag_search: term,
       tag_suggestions: filtered,
       tag_create_option: create_option
     )}
  end

  def handle_event("select_tag", %{"name" => name}, socket) do
    name = String.trim(name)
    selected = socket.assigns.selected_tag_names
    selected_lower = Enum.map(selected, &String.downcase/1)

    new_selected =
      if String.downcase(name) in selected_lower,
        do: selected,
        else: selected ++ [name]

    {:noreply,
     assign(socket,
       selected_tag_names: new_selected,
       tag_search: "",
       tag_suggestions: [],
       tag_create_option: nil
     )}
  end

  def handle_event("remove_tag", %{"name" => name}, socket) do
    new_selected =
      Enum.reject(socket.assigns.selected_tag_names, fn n ->
        String.downcase(n) == String.downcase(name)
      end)

    {:noreply, assign(socket, selected_tag_names: new_selected)}
  end

  def handle_event("publish_now", _params, socket) do
    attrs =
      current_attrs(socket.assigns.changeset, socket.assigns.selected_tag_names)
      |> Map.put(:published_at, DateTime.utc_now())

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

        attrs =
          current_attrs(socket.assigns.changeset, socket.assigns.selected_tag_names)
          |> Map.put(:published_at, utc_dt)

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

  defp current_attrs(changeset, selected_tag_names) do
    current = Ecto.Changeset.apply_changes(changeset)

    %{
      title: current.title,
      content: current.content,
      tag_names: Enum.join(selected_tag_names, ", ")
    }
  end

  defp publish_status(%{published_at: nil}), do: :draft

  defp publish_status(%{published_at: published_at}) do
    if DateTime.compare(published_at, DateTime.utc_now()) == :gt, do: :scheduled, else: :published
  end
end
