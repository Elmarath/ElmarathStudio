# elmarath.com

The site as plain, pre-built HTML pages ([Astro](https://astro.build)): portfolio, blog and the
Unreal Engine plugin docs. Every page is built ahead of time from the Markdown in `../content`, so
the browser only has to show it: scrolling is the browser's own, nothing runs per frame, and pages
load in a fraction of a second.

```bash
npm install        # once
npm run dev        # http://localhost:4321, updates as you edit (drafts show here)
npm run build      # the finished site in dist/ (what Netlify publishes)
npm run preview    # serve dist/ to check a build
npm test           # content checks: URLs, old links, internal links, search
```

## Adding content

Nothing to register: drop a file in `../content` and it's on the site.

| What | Where | Start one with |
| --- | --- | --- |
| Blog post | `content/blog/2026-01-31-my-post.md` (or a folder with `index.md` and its images) | `npm run new-post -- "Title" --tags "Devlog"` |
| Doc page | `content/docs/<Plugin-Folder>/My-Page.md` | `npm run new-doc -- Plugin-Folder "Page title"` |
| Plugin (docs folder) | `content/docs/<Plugin-Folder>/_category_.yaml` (name, pitch, thumbnail, Fab link, `featured`) | `new-doc` makes one with a new folder |
| Page | `content/pages/<slug>.md` → `/<slug>` | |
| Case study | `content/work/<slug>/index.md` (shown once `showWork` is on) | `npm run new-work -- "Project"` |

- **Drafts:** `draft: true` in the front matter shows a post or case study in `npm run dev` only.
- **Images:** put them next to the Markdown and link them relatively (`![Alt](./img/shot.png)`).
  They're converted to WebP at several widths automatically, sized (no layout jumps), lazy-loaded,
  and open full size on click. GIFs stay animated.
- **Markdown extras** (as on the old Docusaurus site): `:::note Title` … `:::` callouts (`note`,
  `tip`, `info`, `warning`, `danger`, nestable), GitHub `> [!NOTE]` alerts, `::youtube <link>`
  (loads only when played), `::plugin-links` (the plugin's Fab/GitHub buttons), ```` ```cpp ````
  highlighted code with a copy button, ```` ```mermaid ```` diagrams, tables.
- **Old links keep working:** every address of the previous site redirects to its page (made into
  Netlify's `_redirects` at build time), and the 404 page matches anything else loosely (letter
  case, dashes, renamed folders: `aliases:` in `_category_.yaml`). Pages that moved entirely go in
  `movedPages` in `src/config.ts`.

## Changing the site

- **Names, links, menus, hero text, showreel clips, analytics, Work on/off:** `src/config.ts`.
- **Files served as they are** (showreel videos and stills, icons, logo, CV): `public/`.
- **Colors / themes:** `src/styles/themes.css` (one block per theme) and `themes` in `src/config.ts`.
- **Home page sections:** `src/pages/index.astro`, one line per section.
- **Pages:** `src/pages/` (the file path is the URL). Components are in `src/components/`, with their
  styles inside them. Shared styles: `src/styles/global.css`; Markdown styles: `src/styles/prose.css`.
- **Content loading** (front matter, the docs tree, URLs, search): `src/content/repository.ts`.
  **Markdown rendering** and its extras: `src/content/markdown.ts` and `markdown-source.ts`.

## Why it's fast

- **No framework in the browser.** Pages are finished HTML. The only script on every page (~5 kB)
  waits for clicks: theme menu, search, CV window, image zoom, copy buttons.
- **Work done at build time, not on screen:** code highlighting, image resizing, the hero glow and
  the carousel's blurred backgrounds are all made once by `npm run build` (`scripts/media.mjs`).
- **Only the compositor animates.** Hovers, the hero glow and page transitions change `transform`
  and `opacity` only, which the browser animates without repainting. The showreel and the carousel
  pause when they're off screen.
- **Loaded only when needed:** the search index loads when search opens, the YouTube player when a
  video is played, the diagram library only on pages with a diagram, and images as they scroll in.
  Hovering a link fetches its page in advance, so opening it is instant.
