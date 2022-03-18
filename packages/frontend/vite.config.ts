import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tsconfigPaths from "vite-tsconfig-paths";
import { resolve } from "path";
import { visualizer } from "rollup-plugin-visualizer";

// https://vitejs.dev/config/
export default defineConfig({
    base: "/",
    plugins: [react(), tsconfigPaths()],
    build: {
        sourcemap: true,
        rollupOptions: {
            plugins: [
                visualizer({
                    filename: resolve(__dirname, "stats/stats.html"),
                    template: "treemap", // sunburst|treemap|network
                    sourcemap: true,
                }),
            ],
        },
    },
});
