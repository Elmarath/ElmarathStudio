# elmarath.com

Portfolio, devlog and Unreal Engine plugin documentation of Denizhan Toprak, at
[elmarath.com](https://elmarath.com).

```
content/   Everything you write, as Markdown: blog posts, plugin docs, pages, case studies.
site/      The website (Astro): turns content/ into fast, plain HTML pages.
```

## Run it

```bash
cd site
npm install      # once
npm run dev      # http://localhost:4321, updates as you edit (drafts show here)
```

## Publish

Push to `master`. Netlify builds `site/` (see `netlify.toml`) and the new version is live a minute later.

## Write

```bash
cd site
npm run new-post -- "Shipping the Dialogue System" --tags "Unreal, Devlog"
npm run new-doc  -- Nested-Inventory-Architecture "Saving and Loading"
npm run new-work -- "Thrall Guard"
npm run video    -- ~/Exports/clip.mov ../content/blog/my-post   # a small silent loop, instead of a GIF
```

Each makes a Markdown file in `content/` to fill in (as a draft where that applies). Drop images next
to it and link them relatively. [site/README.md](site/README.md) covers the Markdown extras (callouts,
YouTube, code, diagrams), the site's settings, and how it's built.
