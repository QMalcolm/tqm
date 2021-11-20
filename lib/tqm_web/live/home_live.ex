defmodule TqmWeb.HomeLive do
  use TqmWeb, :live_view

  def render(assigns) do
    ~L"""
    <%= live_component @socket, TqmWeb.NavbarComponent %>
    <h1>This is my website<h1>
    """
  end
end
