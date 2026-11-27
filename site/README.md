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
| Work entry (a studio, project or plugin) | `content/work/<slug>/index.md`: a picture or clip, one main link, a 50–100 word summary, and optional widgets (impact numbers, "What I did" tiles, code spotlight, milestones, a quote) | `npm run new-work -- "Project"` |

- **Drafts:** `draft: true` in the front matter shows a post or case study in `npm run dev` only.
- **Images:** put them next to the Markdown and link them relatively (`![Alt](./img/shot.png)`).
  They're converted to WebP at several widths automatically, sized (no layout jumps), lazy-loaded,
  and open full size on click. GIFs stay animated, but use a clip instead (below).
- **Looping clips (instead of GIFs):** export from your editor, then make a small silent clip next to
  the Markdown (needs ffmpeg once: `brew install ffmpeg`):

  ```bash
  npm run video -- ~/Exports/build-mode.mov ../content/blog/my-post --size inline
  ```

  It writes `build-mode.mp4` (H.264, plays everywhere), `build-mode.av1.mp4` (smaller, for browsers
  that can play it) and `build-mode.jpg` (the poster); commit those, not the export. Show it with
  `::video ./build-mode.mp4 Optional caption` in a post or doc, or with `video: build-mode.mp4` in a
  post's or case study's front matter (it replaces the cover, on the cards too).
  Clips always play, muted and on repeat, while they're on screen, and pause when scrolled away.

  | `--size` | Width | For | Budget (AV1 file) |
  | --- | --- | --- | --- |
  | `card` | 960 px | covers and cards | under 1 MB |
  | `inline` (default) | 1280 px | inside a post or doc | under 3 MB |
  | `hero` | 1600 px | full width | under 5 MB |

  It picks the settings itself: for each format it searches for the smallest file that still
  looks like your export (a VMAF score of 93/100), and only softens it further if that's over the
  size's budget, telling you when it did. It keeps the export's frame rate (at most 30). 4–10
  seconds loops best. Options: `--length 6` and `--start 3` to cut, `--quality 95` for sharper,
  `--fps 30`, or `--crf 28` to skip the search.
- **Markdown extras** (as on the old Docusaurus site): `:::note Title` … `:::` callouts (`note`,
  `tip`, `info`, `warning`, `danger`, nestable), GitHub `> [!NOTE]` alerts, `::youtube <link>`
  (loads only when played), `::video ./clip.mp4 Caption` (a looping clip), `::plugin-links` (the plugin's Fab/GitHub buttons), ```` ```cpp ````
  highlighted code with a copy button, ```` ```mermaid ```` diagrams, tables.
- **Old links keep working:** every address of the previous site redirects to its page (made into
  Netlify's `_redirects` at build time), and the 404 page matches anything else loosely (letter
  case, dashes, renamed folders: `aliases:` in `_category_.yaml`). Pages that moved entirely go in
  `movedPages` in `src/config.ts`.

## Editing on the website

Open **[elmarath.com/admin](https://elmarath.com/admin)** to edit the docs (every plugin folder, plus
the intro) and the pages in the browser. It's [Sveltia CMS](https://sveltiacms.app): saving makes a
commit to `master` on GitHub, Netlify rebuilds, and the change is live a minute later. The Markdown in
`content/` stays the only copy, so VS Code and the website editor can be used side by side (pull
before editing locally).

- **The pencil "Edit" button** at the top right of every docs page opens that page in the editor.
  Only you see it: it appears in a browser that's signed in to `/admin`, and is hidden for everyone
  else (sign out of the editor and it's gone).
- **Bodies are edited as plain Markdown**, exactly as in VS Code, so callouts, `::youtube`,
  `::video`, `::plugin-links` and code blocks stay as written. (The rich text mode is switched off:
  it would rewrite them.) The preview beside the editor doesn't know the site's extras; check the page
  itself after it's built.
- **Images** you add go in the folder's `img/` and are linked as `img/name.png`, like the existing ones.
- **Front matter** keys the editor doesn't show are kept. It does rewrite the front matter's formatting
  (quotes, order of the keys it knows).
- **New plugin folders** appear in the editor by themselves (the list is made at build time:
  `src/content/cms.ts`). Blog posts and case studies aren't in it yet; they're still edited here.
- **Visitors get nothing of it:** the Edit button stays hidden for them, the editor's script loads only on `/admin`,
  and `/admin` is kept out of search engines (`robots.txt`, `netlify.toml`).
- **Only you can save:** signing in needs write access to the GitHub repository.

One-time setup, so "Sign In with GitHub" works on the live site:

1. On GitHub, **Settings → Developer settings → OAuth Apps → New OAuth App**
   (github.com/settings/applications/new): any name, homepage `https://elmarath.com`, and
   **Authorization callback URL** `https://api.netlify.com/auth/done`. Copy the Client ID and generate
   a Client Secret.
2. In Netlify, **Project configuration → Security → OAuth** (not Identity) → **Install provider** →
   GitHub, and paste the Client ID and Secret.

Without that setup, "Sign In Using Access Token" works too: a fine-grained GitHub token limited to this
repository with **Contents: read and write**.

Locally, with no sign-in: run `npm run dev`, open `http://localhost:4321/admin` in Chrome or Edge,
choose **Work with Local Repository** and pick the repository folder (the one holding `content/`).
Edits are saved to your files; commit them as usual.

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
  and `opacity` only, which the browser animates without repainting. The showreel, the carousel and
  looping clips pause when they're off screen; a clip downloads only when it nears the screen.
- **Loaded only when needed:** the search index loads when search opens, the YouTube player when a
  video is played, the diagram library only on pages with a diagram, and images as they scroll in.
  Hovering a link fetches its page in advance, so opening it is instant.
