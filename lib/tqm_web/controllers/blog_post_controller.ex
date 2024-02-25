defmodule TqmWeb.BlogPostController do
  use TqmWeb, :controller

  alias Tqm.Blog
  alias Tqm.Blog.BlogPost

  def index(conn, _params) do
    blog_posts =
      conn.assigns[:current_person]
      |> Blog.list_blog_posts()

    render(conn, :index, tlp: :blog, blog_posts: blog_posts)
  end

  def new(conn, _params) do
    changeset = Blog.change_blog_post(%BlogPost{})
    render(conn, :new, tlp: :blog, changeset: changeset)
  end

  def create(conn, %{"blog_post" => blog_post_params}) do
    case Blog.create_blog_post(blog_post_params) do
      {:ok, blog_post} ->
        conn
        |> put_flash(:info, "Blog post created successfully.")
        |> redirect(to: ~p"/blog/#{blog_post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, tlp: :blog, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    blog_post = Blog.get_blog_post!(id)
    render(conn, :show, blog_post: blog_post, tlp: :blog)
  end

  def edit(conn, %{"id" => id}) do
    blog_post = Blog.get_blog_post!(id)
    changeset = Blog.change_blog_post(blog_post)
    render(conn, :edit, blog_post: blog_post, tlp: :blog, changeset: changeset)
  end

  def update(conn, %{"id" => id, "blog_post" => blog_post_params}) do
    blog_post = Blog.get_blog_post!(id)

    case Blog.update_blog_post(blog_post, blog_post_params) do
      {:ok, blog_post} ->
        conn
        |> put_flash(:info, "Blog post updated successfully.")
        |> redirect(to: ~p"/blog/#{blog_post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, blog_post: blog_post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    blog_post = Blog.get_blog_post!(id)
    {:ok, _blog_post} = Blog.delete_blog_post(blog_post)

    conn
    |> put_flash(:info, "Blog post deleted successfully.")
    |> redirect(to: ~p"/blog")
  end
end
