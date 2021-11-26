defmodule TqmWeb.NavbarComponent do
  use TqmWeb, :live_component

  # bbg loves bbq 11/26/2021 <3 <3 <3

  defp is_active_path(socket, nav_name) do
    view = socket.view
    case nav_name do
      :home -> view == TqmWeb.HomeLive
      :about -> view == TqmWeb.AboutLive
    end
  end
end
