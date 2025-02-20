defmodule Game do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "games" do
    field :email, :string
    field :name, :string
    field :score, :integer
    field :game_over, :integer, default: 0
    timestamps(type: :utc_datetime)
  end
end
