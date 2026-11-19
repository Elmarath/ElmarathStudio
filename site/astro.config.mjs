// @ts-check
import { defineConfig } from 'astro/config';

// A static site: every page is HTML built ahead of time from ../content.
export default defineConfig({
  site: 'https://elmarath.com',
  // `/docs/intro`, not `/docs/intro/`, matching the old site's addresses.
  trailingSlash: 'never',
  build: { format: 'file' },
  // Pages a visitor is about to open (hovering or touching a link) are fetched
  // in the background, so moving between pages is instant.
  prefetch: { prefetchAll: true, defaultStrategy: 'hover' },
  devToolbar: { enabled: false },
  vite: {
    // Content lives one folder up (../content), shared with nothing else.
    server: { fs: { allow: ['..'] } },
  },
});
