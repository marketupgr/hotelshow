defmodule GameWeb.AdminController do
  use GameWeb, :controller
  alias Game.Repo
  import Ecto.Query

  plug :auth

  defp auth(conn, _opts) do
    password = System.fetch_env!("ADMIN_PASSWORD")
    Plug.BasicAuth.basic_auth(conn, username: "marketup", password: password)
  end

  def signups(conn, _params) do
    games = Repo.all(from g in Game, where: not is_nil(g.name), order_by: [desc: g.inserted_at])
    render(conn, :signups, games: games)
  end
end
