defmodule TqmWeb.AboutLive.Index do
  use TqmWeb, :live_view

  alias Tqm.Jobs

  defp process_extra_jobs_info(jobs) do
    Enum.map(jobs, fn job ->
      job
      |> Map.put(:start_date, Jobs.job_start_date(job))
      |> Map.put(:end_date, Jobs.job_end_date(job))
      |> Map.put(:rendered_work_description, Earmark.as_html!(job.work_description))
    end)
  end

  defp compare_jobs(job_a, job_b) do
    Date.compare(job_a.start_date, job_b.start_date) != :lt
  end

  defp sort_jobs_by_start_date(jobs) do
    Enum.sort(jobs, &compare_jobs(&1, &2))
  end

  @impl true
  def mount(_params, _session, socket) do
    jobs =
      [:roles]
      |> Jobs.list_jobs()
      |> process_extra_jobs_info()
      |> sort_jobs_by_start_date()

    socket =
      socket
      |> assign(:tlp, :about)
      |> assign(:jobs, jobs)
      |> assign(:expanded_job_ids, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle-job-details", %{"job-id" => job_id}, socket) do
    expanded_job_ids = socket.assigns[:expanded_job_ids]

    if Enum.member?(expanded_job_ids, job_id) do
      {:noreply, assign(socket, :expanded_job_ids, List.delete(expanded_job_ids, job_id))}
    else
      {:noreply, assign(socket, :expanded_job_ids, [job_id | expanded_job_ids])}
    end
  end
end
