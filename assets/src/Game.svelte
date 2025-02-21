<script lang="ts">
  let { shooken, start }: { shooken: () => void; start: () => void } = $props();
  let started = $state(false);

  function startEvents() {
    start();

    const ACCELERATION_THRESHOLD = 20;
    const TIME_WINDOW = 100;
    let lastEventTime = 0;

    window.addEventListener('devicemotion', (event) => {
      const currentTime = Date.now();

      if (currentTime - lastEventTime >= TIME_WINDOW) {
        if (event.acceleration) {
          const { x, y, z } = event.acceleration;
          if ((x && x >= ACCELERATION_THRESHOLD) || (y && y >= ACCELERATION_THRESHOLD) || (z && z >= ACCELERATION_THRESHOLD)) {
            shooken();
            lastEventTime = currentTime;
          }
        }
      }
    });

    started = true;
	}

  function startGame() {
    if (typeof DeviceOrientationEvent.requestPermission === 'function') {
      DeviceOrientationEvent.requestPermission().then((response: any) => {
        if (response === 'granted') {
          startEvents();
        }
      });
    } else {
      startEvents();
    }
  }
</script>

{#if !started}
  <button
    onclick={startGame}
    class="bg-white text-brand text-4xl font-medium px-7 py-5 w-64 cursor-pointer rounded fixed top-1/2 left-1/2 -translate-x-1/2"
  >
    Ξεκίνα
  </button>
{/if}
