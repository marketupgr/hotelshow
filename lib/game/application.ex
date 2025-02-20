defmodule Game.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GameWeb.Telemetry,
      Game.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:game, :ecto_repos), skip: skip_migrations?()},
      {Phoenix.PubSub, name: Game.PubSub},
      GameWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Game.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GameWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
