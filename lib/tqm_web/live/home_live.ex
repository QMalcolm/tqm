defmodule TqmWeb.HomeLive do
  use TqmWeb, :live_view

  def render(assigns) do
    ~L"""
    <h1>This is my website<h1>
    """
  end
end
