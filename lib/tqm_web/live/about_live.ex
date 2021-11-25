defmodule TqmWeb.AboutLive do
  use TqmWeb, :live_view
  # Honestly this is a static page so having it as a liveview page is
  # a bit of over kill, but meh, oh well

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
