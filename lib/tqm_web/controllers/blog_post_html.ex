defmodule TqmWeb.BlogPostHTML do
  @moduledoc false
  use TqmWeb, :html

  embed_templates "blog_post_html/*"

  def reading_time(content) when is_binary(content) do
    words = content |> String.split(~r/\s+/) |> length()
    minutes = max(1, round(words / 200))
    "#{minutes} min read"
  end
end
