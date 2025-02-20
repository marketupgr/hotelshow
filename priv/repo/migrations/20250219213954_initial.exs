defmodule Game.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :score, :integer
      add :email, :string
      add :name, :string
      add :game_over, :integer
      timestamps(type: :utc_datetime)
    end
  end
end
