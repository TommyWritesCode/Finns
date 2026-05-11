# Starter — read me before you change things

This is the starter scaffold the framework drops into a fresh client repo.

## What is here

- `package.json` — Astro 5, Tailwind v4 (via `@tailwindcss/vite`), Wrangler, Astro check.
- `astro.config.mjs` — static output, Tailwind plugin, directory routing.
- `tsconfig.json` — Astro strict preset.
- `wrangler.toml` — Cloudflare Workers static-asset deploy. Rename `name` per client.
- `src/layouts/Layout.astro` — base HTML, head metadata, OG/Twitter, skip link.
- `src/components/Header.astro` and `Footer.astro` — minimal nav + footer with mobile disclosure menu.
- `src/pages/index.astro` — placeholder home page with `[NEEDS: ...]` markers.
- `src/data/seo.json` — site-wide SEO defaults; per-page entries layered on top.
- `src/styles/global.css` — Tailwind import + brand tokens.
- `public/favicon.svg`, `public/robots.txt` — minimum public assets.

## Build commands (after `npm install`)

- `npm run dev` — local dev server.
- `npm run build` — production build into `dist/`.
- `npm run check` — Astro type/diagnostic check.
- `npm run deploy` — build then `wrangler deploy`.

## Notes for the builder agent

- Brand color tokens live in `src/styles/global.css` under `@theme` — change them there, not in components.
- `[NEEDS: ...]` markers are intentional. The static checker (`scripts/check-site.mjs`) flags them and the rubric grader will fail the site if any survive into the public pages.
- Default routing is directory-style (`/about` resolves to `src/pages/about.astro` or `src/pages/about/index.astro`).
- Replace `wrangler.toml` `name` with a client-specific slug before first deploy.
