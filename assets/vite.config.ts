import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig(({ mode }) => ({
  plugins: [svelte(), tailwindcss()],
  build: {
    lib: {
      entry: "src/main.ts",
      formats: ["es"],
    },
    outDir: "../priv/static/assets",
    emptyOutDir: true,
    sourcemap: mode === "development" ? "inline" : false,
    rollupOptions: {
      input: "src/main.ts",
    },
  },
}));
