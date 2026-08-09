defmodule TqmWeb.JobLive.Form do
  use TqmWeb, :live_view

  alias Tqm.Jobs
  alias Tqm.Jobs.Job

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, tlp: :about)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    job = id |> Jobs.get_job!([:roles]) |> sort_roles()

    {:noreply,
     assign(socket,
       job: job,
       form: to_form(Jobs.change_job(job)),
       page_title: "Edit job"
     )}
  end

  def handle_params(_params, _url, socket) do
    job = %Job{roles: []}

    {:noreply,
     assign(socket,
       job: job,
       form: to_form(Jobs.change_job(job)),
       page_title: "New job"
     )}
  end

  @impl true
  def handle_event("validate", %{"job" => params}, socket) do
    changeset =
      socket.assigns.job
      |> Jobs.change_job(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"job" => params}, socket) do
    save_job(socket, socket.assigns.live_action, params)
  end

  def handle_event("delete", _params, socket) do
    {:ok, _job} = Jobs.delete_job(socket.assigns.job)

    {:noreply,
     socket
     |> put_flash(:info, "Job deleted.")
     |> push_navigate(to: ~p"/about")}
  end

  defp save_job(socket, :new, params) do
    Jobs.create_job(params) |> apply_job_result(socket, "Job created.")
  end

  defp save_job(socket, :edit, params) do
    Jobs.update_job(socket.assigns.job, params) |> apply_job_result(socket, "Job updated.")
  end

  defp apply_job_result({:ok, _job}, socket, flash_msg) do
    {:noreply,
     socket
     |> put_flash(:info, flash_msg)
     |> push_navigate(to: ~p"/about")}
  end

  defp apply_job_result({:error, changeset}, socket, _flash_msg) do
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  # Present roles newest-first, matching the about page.
  defp sort_roles(%Job{} = job) do
    %{job | roles: Enum.sort_by(job.roles, & &1.start_date, {:desc, Date})}
  end

  def field_errors(%Phoenix.HTML.FormField{errors: errors}) do
    Enum.map(errors, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
