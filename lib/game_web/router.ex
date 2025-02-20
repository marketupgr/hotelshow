defmodule GameWeb.Router do
  use GameWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GameWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", GameWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/board", PageController, :board
    get "/thanks", PageController, :thanks
    get "/signups", AdminController, :signups
    post "/board/new", PageController, :new_game
    live "/game/:id/player", GameLive, :player
    live "/game/:id/host", GameLive, :host
  end
end
