defmodule TqmWeb.LiveComponents.JobWithTogglableDetails do
  @moduledoc """
  Provides UI components for Jobs.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use TqmWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :show_details, false)
    {:ok, socket}
  end

  def handle_event("toggle-job-details", _params, socket) do
    show_details = socket.assigns[:show_details]
    {:noreply, assign(socket, :show_details, not show_details)}
  end

  @doc """
  Renders a role

  ## Examples
  <.live_component module={ExpandableJob} job={@job} />
  """

  def render(assigns) do
    ~H"""
    <div>
      <div
        id={"summary-#{@job.id}"}
        phx-click="toggle-job-details"
        phx-target={@myself}
        class="bg-gray-200 flex flex-wrap space-x-3 mb-2 px-3"
        style="cursor: pointer;"
      >
        <div>
          <span class="text-xl" style="line-height: 3.5rem;">
            <%= if @show_details, do: "-", else: "+" %>
          </span>
        </div>
        <div>
          <img src={@job.logo} alt={"Logo of #{@job.company_name}"} link={@job.url} class="h-10 my-2" />
        </div>
        <div>
          <span class="text-xl" style="line-height: 3.5rem;">
            <%= @job.company_name %>
          </span>
        </div>
        <div>
          <span style="line-height: 3.5rem; margin-left: auto; order: 2;">
            <%= Calendar.strftime(@job.start_date, "%b %Y") %> - <%= if @job.end_date == nil,
              do: "Present",
              else: Calendar.strftime(@job.end_date, "%b %Y") %>
          </span>
        </div>
      </div>
      <div style={"#{if not @show_details, do: 'display: none;'}"}>
        <TqmWeb.JobComponents.job_description_and_roles job={@job} />
      </div>
    </div>
    """
  end
end
