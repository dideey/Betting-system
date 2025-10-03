defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session  #support sessions in API
  end

  pipeline :load_user do
    plug AppWeb.Plugs.LoadCurrentUser
  end

  # Create a pipeline for superuser authentication
  pipeline :require_superuser do
    plug AppWeb.Plugs.LoadCurrentUser
    plug AppWeb.Plugs.RequireRole, ["superuser"]
  end

  # API routes
  scope "/api", AppWeb do
    pipe_through :api

    # Authentication endpoints
    post "/auth/login", AuthController, :login
    post "/auth/register", AuthController, :register
    post "/auth/logout", AuthController, :logout

    #Bettin endpoints
    post "/bets", BetController, :create
    delete "/bets/:id", BetController, :cancel
    get "/bets", BetController, :index

  end

  # Superuser API routes
  scope "/api/superuser", AppWeb do
    pipe_through [:api, :require_superuser]

    # Game management
    post "/games", Superuser.GameController, :create
    get "/games", Superuser.GameController, :index
    put "/games/:id", Superuser.GameController, :update
    delete "/games/:id", Superuser.GameController, :delete
    post "/games/:id/resolve", Superuser.GameController, :resolve
    get "/games/:id/profit", Superuser.GameController, :profit


    # User management
    post "/users/:id/role", Superuser.UserController, :set_role
    delete "/users/:id", Superuser.UserController, :soft_delete
    get "/users/:id", Superuser.UserController, :show

    #B
  end

  # Browser routes (if you need them)
  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
