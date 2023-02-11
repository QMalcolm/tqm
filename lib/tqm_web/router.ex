defmodule TqmWeb.Router do
  use TqmWeb, :router

  import TqmWeb.PersonAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TqmWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_person
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  ## Routes requiring :owner person role
  scope "/", TqmWeb do
    pipe_through [:browser, :require_owner_person]
    resources "/blog", BlogPostController, except: [:show, :index]
  end

  ## Unauthed routes
  scope "/", TqmWeb do
    pipe_through :browser

    get "/", PageController, :home
    resources "/blog", BlogPostController, only: [:index, :show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", TqmWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tqm, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TqmWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TqmWeb do
    pipe_through [:browser, :redirect_if_person_is_authenticated]

    live_session :redirect_if_person_is_authenticated,
      on_mount: [{TqmWeb.PersonAuth, :redirect_if_person_is_authenticated}] do
      live "/people/register", PersonRegistrationLive, :new
      live "/people/log_in", PersonLoginLive, :new
      live "/people/reset_password", PersonForgotPasswordLive, :new
      live "/people/reset_password/:token", PersonResetPasswordLive, :edit
    end

    post "/people/log_in", PersonSessionController, :create
  end

  scope "/", TqmWeb do
    pipe_through [:browser, :require_authenticated_person]

    live_session :require_authenticated_person,
      on_mount: [{TqmWeb.PersonAuth, :ensure_authenticated}] do
      live "/people/settings", PersonSettingsLive, :edit
      live "/people/settings/confirm_email/:token", PersonSettingsLive, :confirm_email
    end
  end

  scope "/", TqmWeb do
    pipe_through [:browser]

    delete "/people/log_out", PersonSessionController, :delete

    live_session :current_person,
      on_mount: [{TqmWeb.PersonAuth, :mount_current_person}] do
      live "/people/confirm/:token", PersonConfirmationLive, :edit
      live "/people/confirm", PersonConfirmationInstructionsLive, :new
      live "/about", AboutLive.Index, :index
    end
  end
end
