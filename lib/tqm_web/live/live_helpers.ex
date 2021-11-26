defmodule TqmWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `TqmWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal TqmWeb.BlogPostLive.FormComponent,
        id: @blog_post.id || :new,
        action: @live_action,
        blog_post: @blog_post,
        return_to: Routes.blog_post_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(TqmWeb.ModalComponent, modal_opts)
  end
end
