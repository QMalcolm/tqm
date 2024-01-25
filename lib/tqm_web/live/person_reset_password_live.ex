defmodule TqmWeb.PersonResetPasswordLive do
  use TqmWeb, :live_view

  alias Tqm.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Reset Password</.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="reset_password_form"
        phx-submit="reset_password"
        phx-change="validate"
      >
        <.error :if={@changeset.action == :insert}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={{f, :password}} type="password" label="New password" required />
        <.input
          field={{f, :password_confirmation}}
          type="password"
          label="Confirm new password"
          required
        />
        <:actions>
          <.button phx-disable-with="Resetting..." class="w-full">Reset Password</.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/people/register"}>Register</.link>
        | <.link href={~p"/people/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_person_and_token(socket, params)

    socket =
      case socket.assigns do
        %{person: person} ->
          assign(socket, :changeset, Accounts.change_person_password(person))

        _ ->
          socket
      end

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  # Do not log in the person after reset password to avoid a
  # leaked token giving the person access to the account.
  def handle_event("reset_password", %{"person" => person_params}, socket) do
    case Accounts.reset_person_password(socket.assigns.person, person_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/people/log_in")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"person" => person_params}, socket) do
    changeset = Accounts.change_person_password(socket.assigns.person, person_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end

  defp assign_person_and_token(socket, %{"token" => token}) do
    if person = Accounts.get_person_by_reset_password_token(token) do
      assign(socket, person: person, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end
end
