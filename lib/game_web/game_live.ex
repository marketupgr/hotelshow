defmodule GameWeb.GameLive do
  use GameWeb, :live_view
  alias Game.Repo

  @impl true
  def render(%{game_over: true} = assigns) do
    ~H"""
    <div class="grid place-items-center h-screen w-full">
      <p class="text-3xl font-bold text-white">Το παιχνίδι έχει τελειώσει.</p>
    </div>
    """
  end

  def render(%{live_action: :player} = assigns) do
    ~H"""
    <div
      :if={@state == :started}
      id="timer"
      phx-hook="TimerHook"
      phx-update="ignore"
      data-time={@time}
    />
    <div id="hook" phx-hook="GameHook" phx-update="ignore" />
    <div class="grid place-items-center h-screen w-full">
      <div :if={@state == :started} class="text-6xl font-bold text-white">{@score}</div>
      <div :if={@state == :ended} class="text-white">
        <form phx-submit="save_game" class="flex flex-col w-64 justify-center gap-4 items-center">
          <div class="text-center">
            <p class="text-4xl font-medium">ΤΕΛΙΚΟ ΣΚΟΡ</p>
            <p class="text-5xl font-bold">{@score}</p>
          </div>
          <label class="font-medium space-y-1">
            Email
            <input
              type="email"
              class="bg-orange-900 rounded w-full px-5 py-3 focus:outline-brand"
              name="email"
              placeholder="Το email σας"
              required
            />
          </label>
          <label class="font-medium space-y-1">
            Όνομα
            <input
              class="bg-orange-900 rounded w-full px-5 py-3 focus:outline-brand"
              name="name"
              placeholder="Το όνομά σας"
              required
            />
          </label>
          <button class="bg-orange-800 hover:bg-orange-900 transition-all cursor-pointer w-full px-5 py-3 rounded shadow-lg">
            Εγγραφή στην Κλήρωση
          </button>
        </form>
      </div>
    </div>
    """
  end

  def render(%{live_action: :host} = assigns) do
    ~H"""
    <div
      :if={@state == :started}
      id="timer"
      phx-hook="TimerHook"
      phx-update="ignore"
      data-time={@time}
    />
    <div class="grid place-items-center h-screen w-full">
      <div :if={@state == :started} class="text-6xl font-bold text-white">{@score}</div>
      <div :if={@state == :ended}>
        <div class="text-center">
          <p class="text-4xl font-medium">ΤΕΛΙΚΟ ΣΚΟΡ</p>
          <p class="text-5xl font-bold">{@score}</p>
        </div>
        <.link
          class="block bg-orange-800 text-center hover:bg-orange-900 transition-all cursor-pointer w-full px-5 py-3 rounded shadow-lg mt-4"
          navigate={~p"/board"}
        >
          Πίσω
        </.link>
      </div>
      <div :if={@state == :idle}>
        <p class="text-4xl text-center mb-8 font-bold">Σκάναρε για να ξεκινήσεις</p>
        <div class="p-4 rounded bg-white">
          {Phoenix.HTML.raw(@qrcode)}
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    game = Repo.get!(Game, id)

    if game.game_over == 1 do
      {:ok, assign(socket, :game_over, true)}
    else
      if connected?(socket) do
        Phoenix.PubSub.subscribe(Game.PubSub, "game:#{id}")
      end

      url = GameWeb.Endpoint.url() <> "/game/#{id}/player"
      qrcode = EQRCode.encode(url) |> EQRCode.svg(color: "#df573d")

      {:ok,
       assign(socket,
         time: :timer.seconds(10),
         game: game,
         state: :idle,
         score: 0,
         id: id,
         qrcode: qrcode
       )}
    end
  end

  @impl true
  def handle_event("shooken", _, socket) do
    Phoenix.PubSub.broadcast!(Game.PubSub, "game:#{socket.assigns.id}", :score)
    {:noreply, socket}
  end

  def handle_event("start", _, socket) do
    Phoenix.PubSub.broadcast!(Game.PubSub, "game:#{socket.assigns.id}", :start)
    {:noreply, socket}
  end

  def handle_event("save_game", params, socket) do
    Ecto.Changeset.change(socket.assigns.game,
      name: params["name"],
      email: params["email"],
      score: socket.assigns.score
    )
    |> Repo.update!()

    {:noreply, redirect(socket, to: ~p"/thanks")}
  end

  @impl true
  def handle_info(:score, socket) do
    case socket.assigns do
      %{state: :started} -> {:noreply, update(socket, :score, &(&1 + 1))}
      _ -> {:noreply, socket}
    end
  end

  def handle_info(:start, socket) do
    Process.send_after(self(), :end, socket.assigns.time)
    {:noreply, assign(socket, :state, :started)}
  end

  def handle_info(:end, socket) do
    game =
      Ecto.Changeset.change(socket.assigns.game, %{game_over: 1})
      |> Repo.update!()

    {:noreply,
     socket
     |> assign(:state, :ended)
     |> assign(:game, game)}
  end
end
