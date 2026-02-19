defmodule TqmWeb.PersonConfirmationLive do
  use TqmWeb, :live_view

  alias Tqm.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Confirm Account</.header>

      <.simple_form
        :let={f}
        for={%{}}
        as={:person}
        id="confirmation_form"
        phx-submit="confirm_account"
      >
        <.input field={{f, :token}} type="hidden" value={@token} />
        <:actions>
          <.button phx-disable-with="Confirming..." class="w-full">Confirm my account</.button>
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
    {:ok, assign(socket, token: params["token"]), temporary_assigns: [token: nil]}
  end

  # Do not log in the person after confirmation to avoid a
  # leaked token giving the person access to the account.
  def handle_event("confirm_account", %{"person" => %{"token" => token}}, socket) do
    case Accounts.confirm_person(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Person confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current person and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the person themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_person: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "Person confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
