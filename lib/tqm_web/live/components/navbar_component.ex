defmodule TqmWeb.NavbarComponent do
  use TqmWeb, :live_component

  def render(assigns) do
    ~L"""
    <header>
      <h1>This is my header!</h1>
    </header>
    """
  end
end
