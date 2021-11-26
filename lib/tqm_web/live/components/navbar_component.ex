defmodule TqmWeb.NavbarComponent do
  use TqmWeb, :live_component

  defp is_active_path(socket, nav_name) do
    view = socket.view
    case nav_name do
      :home -> view == TqmWeb.HomeLive
      :about -> view == TqmWeb.AboutLive
    end
  end
end
