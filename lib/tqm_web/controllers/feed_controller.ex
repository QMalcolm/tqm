defmodule TqmWeb.FeedController do
  use TqmWeb, :controller

  alias Tqm.Blog

  def index(conn, _params) do
    base_url = TqmWeb.Endpoint.url()

    blog_posts =
      Blog.list_blog_posts(:published)
      |> Enum.sort_by(& &1.published_at, {:desc, DateTime})

    channel = %{
      title: "Quigley Malcolm",
      description: "Blog posts by Quigley Malcolm",
      self_link: "#{base_url}/blog/feed.xml"
    }

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, build_rss(channel, blog_posts, base_url))
  end

  def tag(conn, %{"tag" => slug}) do
    base_url = TqmWeb.Endpoint.url()

    blog_posts =
      Blog.list_blog_posts(:published, tag: slug)
      |> Enum.sort_by(& &1.published_at, {:desc, DateTime})

    channel = %{
      title: "Quigley Malcolm - #{xml_escape(slug)} posts",
      description: "Blog posts tagged &#34;#{xml_escape(slug)}&#34; by Quigley Malcolm",
      self_link: "#{base_url}/blog/tags/#{slug}/feed.xml"
    }

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, build_rss(channel, blog_posts, base_url))
  end

  defp build_rss(
         %{title: title, description: description, self_link: self_link},
         blog_posts,
         base_url
       ) do
    items =
      Enum.map_join(blog_posts, fn post ->
        """
            <item>
              <title>#{xml_escape(post.title)}</title>
              <link>#{base_url}/blog/#{post.slug}</link>
              <guid>#{base_url}/blog/#{post.slug}</guid>
              <pubDate>#{rss_date(post.published_at)}</pubDate>
              <description><![CDATA[#{post.content}]]></description>
              #{tag_categories(post)}
            </item>
        """
      end)

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>#{title}</title>
        <link>#{base_url}</link>
        <description>#{description}</description>
        <atom:link href="#{self_link}" rel="self" type="application/rss+xml"/>
        #{items}
      </channel>
    </rss>
    """
  end

  defp tag_categories(post) do
    Enum.map_join(post.tags, "\n", fn tag ->
      "          <category>#{xml_escape(tag.name)}</category>"
    end)
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
