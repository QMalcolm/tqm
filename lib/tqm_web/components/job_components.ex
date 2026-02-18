defmodule TqmWeb.JobComponents do
  @moduledoc """
  Provides UI components for jobs.
  """
  use Phoenix.Component

  @doc """
  Renders a jobs description and roles

  ## Examples
  <.job_description_and_roles job = {%Tqm.Jobs.Job{}} />
  """
  attr :job, :string, required: true

  def job_description_and_roles(assigns) do
    ~H"""
    <div>
      <TqmWeb.CoreComponents.markdown_content markdown={@job.description} />
      <%= for role <- @job.roles do %>
        <p class="pt-2">
          <span class="text-xl underline">{role.title}</span>
          <span class="pl-1">
            {Calendar.strftime(role.start_date, "%b %Y")} - {if role.end_date == nil,
              do: "Present",
              else: Calendar.strftime(role.end_date, "%b %Y")}
          </span>
          <TqmWeb.CoreComponents.markdown_content markdown={role.details} />
        </p>
      <% end %>
    </div>
    """
  end
end
