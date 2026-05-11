import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import compress from '@playform/compress';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  output: 'static',
  site: 'https://finnmcools.com',
  trailingSlash: 'never',
  build: {
    format: 'directory',
  },
  vite: {
    plugins: [tailwindcss()],
  },
  integrations: [
    sitemap(),
    compress({
      CSS: true,
      HTML: true,
      JavaScript: true,
      SVG: true,
      Image: false, // we handled images manually
    }),
  ],
});
