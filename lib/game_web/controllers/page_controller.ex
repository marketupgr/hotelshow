defmodule GameWeb.PageController do
  use GameWeb, :controller
  import Ecto.Query
  alias Game.Repo

  def home(conn, _params) do
    render(conn, :home)
  end

  def board(conn, _params) do
    games =
      Repo.all(
        from g in Game,
          where: not is_nil(g.name) and not is_nil(g.score),
          order_by: [desc: g.score],
          limit: 10
      )

    games = Enum.reduce(0..9, [], fn i, acc -> [Enum.at(games, i) | acc] end) |> Enum.reverse()

    render(conn, :board, games: games)
  end

  def thanks(conn, _params) do
    render(conn, :thanks)
  end

  def new_game(conn, _params) do
    game = Repo.insert!(%Game{})

    conn
    |> redirect(to: ~p"/game/#{game.id}/host")
  end
end
