defmodule TqmWeb.PageController do
  use TqmWeb, :controller

  alias Tqm.Blog

  def home(conn, _params) do
    recent_posts =
      Blog.list_blog_posts(:published)
      |> Enum.take(3)

    render(conn, :home, tlp: :home, page_padding: false, recent_posts: recent_posts)
  end

  def about(conn, _params) do
    render(conn, :about, tlp: :about)
  end
end
