defmodule TqmWeb.PageController do
  use TqmWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
