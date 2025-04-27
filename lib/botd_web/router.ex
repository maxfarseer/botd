defmodule BotdWeb.Router do
  use BotdWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BotdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :admin do
    plug :browser
    plug :protected
    plug BotdWeb.Plugs.EnsureRole, :admin
  end

  pipeline :moderator do
    plug :browser
    plug :protected
    plug BotdWeb.Plugs.EnsureRole, [:admin, :moderator]
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", BotdWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/people", PersonController, :index
    get "/people/:id", PersonController, :show
  end

  scope "/protected", BotdWeb do
    pipe_through :moderator

    get "/people/new", PersonController, :new
    post "/people", PersonController, :create
    get "/people/:id/edit", PersonController, :edit
    put "/people/:id", PersonController, :update
    patch "/people/:id", PersonController, :update
    delete "/people/:id", PersonController, :delete
  end

  # Member routes - only authenticated users
  scope "/suggestions", BotdWeb do
    pipe_through [:browser, :protected]

    get "/new", SuggestionController, :new
    post "/", SuggestionController, :create
    get "/my", SuggestionController, :my_suggestions
  end

  # Moderator routes - for reviewing suggestions
  scope "/protected", BotdWeb do
    pipe_through :moderator

    get "/suggestions", SuggestionController, :index
    get "/suggestions/:id", SuggestionController, :show
    post "/suggestions/:id/approve", SuggestionController, :approve
    post "/suggestions/:id/reject", SuggestionController, :reject
  end

  # Admin-only routes
  scope "/admin", BotdWeb do
    pipe_through :admin

    get "/logs", ActivityLogController, :index
    get "/logs-test", ActivityLogController, :index_test
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
end
