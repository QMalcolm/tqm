defmodule TqmWeb.FeedController do
  use TqmWeb, :controller

  alias Tqm.Blog

  def index(conn, _params) do
    blog_posts =
      Blog.list_blog_posts(:published)
      |> Enum.sort_by(& &1.published_at, {:desc, DateTime})

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, rss_feed(blog_posts))
  end

  defp rss_feed(blog_posts) do
    base_url = TqmWeb.Endpoint.url()

    items =
      Enum.map_join(blog_posts, fn post ->
        """
            <item>
              <title>#{xml_escape(post.title)}</title>
              <link>#{base_url}/blog/#{post.id}</link>
              <guid>#{base_url}/blog/#{post.id}</guid>
              <pubDate>#{rss_date(post.published_at)}</pubDate>
              <description><![CDATA[#{post.content}]]></description>
            </item>
        """
      end)

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>Quigley Malcolm</title>
        <link>#{base_url}</link>
        <description>Blog posts by Quigley Malcolm</description>
        <atom:link href="#{base_url}/blog/feed.xml" rel="self" type="application/rss+xml"/>
        #{items}
      </channel>
    </rss>
    """
  end

  defp rss_date(datetime) do
    Calendar.strftime(datetime, "%a, %d %b %Y %H:%M:%S +0000")
  end

  defp xml_escape(str) do
    str
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
end
