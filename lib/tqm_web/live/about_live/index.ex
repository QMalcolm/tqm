defmodule TqmWeb.AboutLive.Index do
  use TqmWeb, :live_view

  alias Tqm.Jobs

  defp job_year_start(job) do
    case job.roles do
      [] -> nil
      roles -> roles |> Enum.map(& &1.start_date) |> Enum.min(Date)
    end
  end

  defp job_year_end(job) do
    case job.roles do
      [] ->
        nil

      roles ->
        if Enum.any?(roles, &is_nil(&1.end_date)),
          do: nil,
          else: roles |> Enum.map(& &1.end_date) |> Enum.max(Date)
    end
  end

  defp sort_jobs(jobs) do
    Enum.sort_by(jobs, &job_year_start/1, {:desc, Date})
  end

  # Roles come back from the database in unspecified order; display them
  # newest-first, matching the job ordering.
  defp sort_roles(job) do
    %{job | roles: Enum.sort_by(job.roles, & &1.start_date, {:desc, Date})}
  end

  defp format_year(nil), do: "Present"
  defp format_year(date), do: Calendar.strftime(date, "%Y")

  def job_year_range(job) do
    start_year = job_year_start(job) |> format_year()
    end_year = job_year_end(job) |> format_year()
    if start_year == end_year, do: start_year, else: "#{start_year} — #{end_year}"
  end

  def current_role_title(job) do
    case job.roles do
      [] ->
        ""

      roles ->
        roles
        |> Enum.sort_by(& &1.start_date, {:desc, Date})
        |> hd()
        |> Map.get(:title)
    end
  end

  # Default colors per job position (cycles through a palette)
  @dot_colors ~w(#FF694A #5B4FE6 #7CB342 #1A1612 #5DBFB9 #3B5998 #1E73BE #C0392B #8B2840 #F39C12)

  def job_color(job) do
    Enum.at(@dot_colors, rem(job.id - 1, length(@dot_colors)), "#7A6E62")
  end

  @impl true
  def mount(_params, _session, socket) do
    jobs = Jobs.list_jobs([:roles]) |> Enum.map(&sort_roles/1) |> sort_jobs()

    {:ok,
     assign(socket,
       tlp: :about,
       page_title: "About",
       jobs: jobs,
       expanded_jobs: MapSet.new()
     )}
  end

  @impl true
  def handle_event("toggle_job", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    expanded = socket.assigns.expanded_jobs

    new_expanded =
      if MapSet.member?(expanded, id),
        do: MapSet.delete(expanded, id),
        else: MapSet.put(expanded, id)

    {:noreply, assign(socket, expanded_jobs: new_expanded)}
  end
end
