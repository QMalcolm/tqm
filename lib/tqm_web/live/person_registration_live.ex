defmodule TqmWeb.PersonRegistrationLive do
  use TqmWeb, :live_view

  alias Tqm.Accounts
  alias Tqm.Accounts.Person

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/people/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        id="registration_form"
        for={@changeset}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/people/log_in?_action=registered"}
        method="post"
        as={:person}
      >
        <.error :if={@changeset.action == :insert}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={{f, :email}} type="email" label="Email" required />
        <.input field={{f, :password}} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_person_registration(%Person{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("save", %{"person" => person_params}, socket) do
    case Accounts.register_person(person_params) do
      {:ok, person} ->
        {:ok, _} =
          Accounts.deliver_person_confirmation_instructions(
            person,
            &url(~p"/people/confirm/#{&1}")
          )

        changeset = Accounts.change_person_registration(person)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", %{"person" => person_params}, socket) do
    changeset = Accounts.change_person_registration(%Person{}, person_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end
end
