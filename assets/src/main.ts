import "./app.css";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { mount } from "svelte";
import Game from "./Game.svelte";
import Timer from "./Timer.svelte";

let csrfToken = document
  ?.querySelector("meta[name='csrf-token']")
  ?.getAttribute("content");

let GameHook = {
  mounted() {
    const shooken = () => {
      this.pushEvent("shooken", {});
    };

    const start = () => {
      this.pushEvent("start", {});
    };

    mount(Game, {
      target: this.el,
      props: { shooken, start },
    });
  },
};

let TimerHook = {
  mounted() {
    mount(Timer, {
      target: this.el,
      props: { time: this.el.dataset.time },
    });
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { GameHook, TimerHook },
});

// connect if there are any LiveViews on the page
liveSocket.connect();
window.liveSocket = liveSocket;
