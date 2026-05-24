defmodule TqmWeb.BlogPostHTML do
  @moduledoc false
  use TqmWeb, :html

  embed_templates "blog_post_html/*"

  def reading_time(content) when is_binary(content) do
    words = content |> String.split(~r/\s+/) |> length()
    minutes = max(1, round(words / 200))
    "#{minutes} min read"
  end

  def reading_time(_), do: "1 min read"

  def format_post_date(%{published_at: nil}), do: nil
  def format_post_date(%{published_at: dt}), do: Calendar.strftime(dt, "%b %-d, %Y")
end
