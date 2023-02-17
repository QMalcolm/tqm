defmodule TqmWeb.PageController do
  use TqmWeb, :controller

  def home(conn, _params) do
    render(conn, :home, tlp: :home, page_padding: false)
  end

  def about(conn, _params) do
    render(conn, :about, tlp: :about)
  end
end
