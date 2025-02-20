<script lang="ts">
	const FRAME_TIME = 1000 / 60;
  let { time }: { time: number } = $props();
  let timeLeft = $state(time);
  let width = $derived((timeLeft / time) * 100);

  const ref = setInterval(() => {
    timeLeft = timeLeft - FRAME_TIME;
    if (timeLeft <= 0) {
      clearInterval(ref);
    }
  }, FRAME_TIME);
</script>

<div class="bg-black h-8 fixed top-0" style:width={`${width}%`}></div>
