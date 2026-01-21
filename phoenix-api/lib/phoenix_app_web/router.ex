defmodule PhoenixAppWeb.Router do
  use PhoenixAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PhoenixAppWeb do
    pipe_through :api
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:phoenix_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).

    scope "/api", PhoenixAppWeb do
      pipe_through :api

      resources "/users", UserController, except: [:new, :edit]

      # Dodatkowa trasa importu
      post "/import", UserController, :import_data
    end
  end
end
