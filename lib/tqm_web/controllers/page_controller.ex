defmodule TqmWeb.PageController do
  use TqmWeb, :controller

  def home(conn, _params) do
    render(conn, :home, tlp: :home, page_padding: false)
  end
end
