defmodule TqmWeb.AboutLive.Index do
  use TqmWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tlp, :about)}
  end
end
