defmodule TqmWeb.PersonLoginLive do
  use TqmWeb, :live_view

  def render(assigns) do
    ~H"""
    <div style="min-height: 70vh; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 24px;">
      <div style="width: 440px; max-width: 100%;">
        <p class="qm-eyebrow">Members only · just one of you</p>
        <h1 class="qm-h1" style="font-size: 54px; margin-bottom: 14px;">
          Welcome <em>back</em>.
        </h1>
        <p style="font-size: 17px; color: var(--muted); margin-bottom: 36px; max-width: 40ch; line-height: 1.55;">
          This is a single-user site. If you're not Quigley, you're probably
          looking for the
          <.link
            navigate={~p"/blog"}
            style="color: var(--ink); text-decoration: none; background-image: linear-gradient(var(--accent), var(--accent)); background-repeat: no-repeat; background-size: 100% 1px; background-position: 0 100%; padding-bottom: 1px;"
          >
            writing
          </.link>
          or the <.link
            navigate={~p"/about"}
            style="color: var(--ink); text-decoration: none; background-image: linear-gradient(var(--accent), var(--accent)); background-repeat: no-repeat; background-size: 100% 1px; background-position: 0 100%; padding-bottom: 1px;"
          >about page</.link>.
        </p>

        <.simple_form
          :let={f}
          id="login_form"
          for={%{}}
          action={~p"/people/log_in"}
          as={:person}
          phx-update="ignore"
          style="display: flex; flex-direction: column; gap: 18px;"
        >
          <div class="qm-field">
            <div class="qm-field-label-row">
              <span class="qm-field-label">Email</span>
            </div>
            <.input field={{f, :email}} type="email" placeholder="quigley@…" label="" />
          </div>
          <div class="qm-field">
            <div class="qm-field-label-row">
              <span class="qm-field-label">Password</span>
              <.link
                href={~p"/people/reset_password"}
                style="font-size: 12px; color: var(--muted); text-decoration: none;"
              >
                Forgot?
              </.link>
            </div>
            <.input
              field={{f, :password}}
              type="password"
              placeholder="••••••••"
              label=""
            />
          </div>
          <:actions :let={f}>
            <label style="display: flex; align-items: center; gap: 10px; font-size: 14px; color: var(--muted); cursor: pointer; margin-top: 4px;">
              <.input field={{f, :remember_me}} type="checkbox" label="Remember me on this device" />
            </label>
          </:actions>
          <:actions>
            <button type="submit" class="qm-btn-dark" phx-disable-with="Signing in…">
              <span>Sign in</span>
              <span style="font-family: var(--serif); font-style: italic; font-size: 20px;">→</span>
            </button>
          </:actions>
        </.simple_form>

        <p style="margin-top: 28px; font-family: var(--mono); font-size: 11px; color: var(--muted); letter-spacing: 0.06em; text-align: center;">
          no public signup · just me on the other side
        </p>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    {:ok, assign(socket, email: email), temporary_assigns: [email: nil]}
  end
end
