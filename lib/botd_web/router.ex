defmodule BotdWeb.Router do
  use BotdWeb, :router

  import BotdWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BotdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :moderator do
    plug :require_authenticated_user
    plug BotdWeb.Plugs.EnsureRole, roles: [:moderator, :admin]
  end

  pipeline :admin do
    plug :require_authenticated_user
    plug BotdWeb.Plugs.EnsureRole, roles: [:admin]
  end

  scope "/", BotdWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/people", PersonController, :index
    get "/people/:id", PersonController, :show
  end

  scope "/protected", BotdWeb do
    pipe_through [:browser, :moderator]

    get "/people/new", PersonController, :new
    post "/people", PersonController, :create
    get "/people/:id/edit", PersonController, :edit
    put "/people/:id", PersonController, :update
    patch "/people/:id", PersonController, :update
    delete "/people/:id", PersonController, :delete
  end

  # Member routes - only authenticated users
  scope "/suggestions", BotdWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/new", SuggestionController, :new
    post "/", SuggestionController, :create
    get "/my", SuggestionController, :my_suggestions
  end

  # Moderator routes - for reviewing suggestions
  scope "/protected", BotdWeb do
    pipe_through [:browser, :moderator]
    # pipe_through :browser

    get "/suggestions", SuggestionController, :index
    get "/suggestions/:id", SuggestionController, :show
    post "/suggestions/:id/approve", SuggestionController, :approve
    post "/suggestions/:id/reject", SuggestionController, :reject
  end

  # Admin-only routes
  scope "/admin", BotdWeb do
    pipe_through [:browser, :admin]

    get "/logs", ActivityLogController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BotdWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:botd, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BotdWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", BotdWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BotdWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", BotdWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BotdWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", BotdWeb do
    pipe_through [:browser, :moderator]

    live_session :require_moderator,
      on_mount: [{BotdWeb.UserAuth, :ensure_authenticated}] do
      live "/telegram/playground", Telegram.PlaygroundLive, :index
    end
  end

  scope "/", BotdWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{BotdWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
