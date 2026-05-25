defmodule TqmWeb.BlogPostLive.Form do
  use TqmWeb, :live_view

  alias Tqm.Blog
  alias Tqm.Blog.BlogPost

  import Tqm.Blog.BlogPost, only: [slugify: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       tlp: :blog,
       scheduling: false,
       publish_status: :draft,
       slug_locked: false,
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
  def handle_event("validate", %{"blog_post" => params}, socket) do
    tag_names = Enum.join(socket.assigns.selected_tag_names, ", ")

    params =
      params
      |> Map.put("tag_names", tag_names)
      |> maybe_inject_slug(socket)

    changeset =
      socket.assigns.blog_post
      |> Blog.change_blog_post(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("lock_slug", %{"blog_post" => params}, socket) do
    current = Ecto.Changeset.apply_changes(socket.assigns.changeset)
    tag_names = Enum.join(socket.assigns.selected_tag_names, ", ")

    attrs = %{
      "title" => current.title,
      "content" => current.content,
      "slug" => params["slug"],
      "tag_names" => tag_names
    }

    changeset =
      socket.assigns.blog_post
      |> Blog.change_blog_post(attrs)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, slug_locked: true, changeset: changeset)}
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

  def handle_event("unpublish", _params, socket) do
    attrs =
      current_attrs(socket.assigns.changeset, socket.assigns.selected_tag_names)
      |> Map.put(:published_at, nil)

    Blog.update_blog_post(socket.assigns.blog_post, attrs)
    |> apply_post_result(socket, "Blog post unpublished.", fn p -> ~p"/blog/#{p}/edit" end)
  end

  def handle_event("publish_now", _params, socket) do
    attrs =
      current_attrs(socket.assigns.changeset, socket.assigns.selected_tag_names)
      |> Map.put(:published_at, DateTime.utc_now())

    Blog.update_blog_post(socket.assigns.blog_post, attrs)
    |> apply_post_result(socket, "Blog post published.", fn p -> ~p"/blog/#{p}" end)
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

        Blog.update_blog_post(socket.assigns.blog_post, attrs)
        |> apply_post_result(socket, "Blog post scheduled.", fn p -> ~p"/blog/#{p}" end)

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Invalid date/time.")}
    end
  end

  defp save_blog_post(socket, :new, params) do
    Blog.create_blog_post(params)
    |> apply_post_result(socket, "Blog post created successfully.", fn p -> ~p"/blog/#{p}" end)
  end

  defp save_blog_post(socket, :edit, params) do
    Blog.update_blog_post(socket.assigns.blog_post, params)
    |> apply_post_result(socket, "Blog post updated successfully.", fn p -> ~p"/blog/#{p}" end)
  end

  defp apply_post_result({:ok, blog_post}, socket, flash_msg, path_fn) do
    {:noreply,
     socket
     |> put_flash(:info, flash_msg)
     |> push_navigate(to: path_fn.(blog_post))}
  end

  defp apply_post_result({:error, changeset}, socket, _flash_msg, _path_fn) do
    {:noreply, assign(socket, changeset: changeset)}
  end

  defp current_attrs(changeset, selected_tag_names) do
    current = Ecto.Changeset.apply_changes(changeset)

    %{
      title: current.title,
      slug: current.slug,
      content: current.content,
      tag_names: Enum.join(selected_tag_names, ", ")
    }
  end

  def status_label(:draft), do: "Draft"
  def status_label(:scheduled), do: "Scheduled"
  def status_label(:published), do: "Published"

  def status_style(:draft), do: "background: var(--bg-alt); color: var(--muted);"
  def status_style(:scheduled), do: "background: var(--accent-soft); color: var(--accent);"
  def status_style(:published), do: "background: #E7F0E9; color: #2F6B3D;"

  def status_dot_color(:draft), do: "var(--muted)"
  def status_dot_color(:scheduled), do: "var(--accent)"
  def status_dot_color(:published), do: "#2F6B3D"

  def field_errors(changeset, field) do
    Keyword.get_values(changeset.errors, field)
    |> Enum.map(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp publish_status(%{published_at: nil}), do: :draft

  defp publish_status(%{published_at: published_at}) do
    if DateTime.compare(published_at, DateTime.utc_now()) == :gt, do: :scheduled, else: :published
  end

  # Auto-populate slug from title for new posts until the user manually edits the slug field.
  defp maybe_inject_slug(params, %{assigns: %{live_action: :new, slug_locked: false}}) do
    Map.put(params, "slug", slugify(params["title"] || ""))
  end

  defp maybe_inject_slug(params, _socket), do: params
end
