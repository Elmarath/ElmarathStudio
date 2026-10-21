# Elmarath Dev Website

Portfolio, dev blog and Docusaurus-style plugin documentation for Elmarath, built with Flutter (web).

- **Home**: hero, site features, a featured-plugin spotlight, latest posts, and a contact section
- **Docs** (`/docs`): sidebar tree, "On this page" table of contents, breadcrumbs, previous/next links
- **Blog** (`/blog`): tag filters, post cards, reading time, author card
- **About** and standalone pages (`/about`, `/privacy-policy`)
- **Search** across everything (⌘K / Ctrl K), and **themes** you can switch from the nav bar

Everything you write is plain Markdown in `content/`. Rebuilding the site never means touching Dart code.

## Run it

```bash
flutter run -d chrome
```

Drafts (`draft: true`) show only while running locally.

Markdown files are bundled as assets, and on the web a hot restart doesn't reload them. After editing content, stop the app and run it again (in VS Code: Shift+F5, then F5). Dart code changes only need a hot restart.

## Write a blog post

```bash
dart run tool/content.dart new-post "Shipping the Dialogue System" --tags "Unreal, Devlog"
```

This creates `content/blog/2026-10-21-shipping-the-dialogue-system.md` as a draft. Add `--folder` to get a folder (`…/index.md`) so images can sit next to the post.

```markdown
---
title: Shipping the Dialogue System
authors: [denizhan]          # from content/blog/authors.yaml
tags: [Unreal, Devlog]
description: Shown on the post card. Falls back to the text above <!-- truncate -->.
image: cover.jpg             # optional cover, relative to this file
draft: true                  # remove to publish
---

Intro paragraph.

<!-- truncate -->

## The rest of the post
```

The date comes from the file name (`YYYY-MM-DD-…`), or from a `date:` field.

## Write documentation

```bash
dart run tool/content.dart new-doc Dialogue-System "Getting Started"
```

Each folder in `content/docs/` is a sidebar section (usually one plugin). Subfolders nest. A folder's `_category_.yaml` describes it:

```yaml
label: "Dialogue System"
position: 10                  # order in the sidebar
summary: One line shown on cards.
description: Longer text for the overview page.
thumbnail: thumbnail.png      # square image in this folder
featured: true                # show in the home page spotlight
links:
  fab: https://www.fab.com/listings/...
  github: https://github.com/...
```

Doc front matter uses Docusaurus keys: `title`, `sidebar_label`, `sidebar_position`, `description`, `slug`. A leading `# Heading` becomes the page title. An `index.md` in a folder replaces the generated overview page.

The docs were ported from the Docusaurus site, so old links such as `/docs/Easy-Ability-Set-System/AbilitySets` still resolve.

## Markdown features

Standard GitHub-flavored Markdown (tables, task lists, strikethrough, fenced code with syntax highlighting), plus:

| Write | Get |
| --- | --- |
| `:::note Optional title` … `:::` | Callout. Types: `note`, `tip`, `info`, `warning`, `danger` |
| `> [!TIP]` | GitHub-style callout, same look |
| `::youtube a8clpcFSLOE start=90` | YouTube player (a URL works too) |
| `::plugin-links` | Fab / GitHub buttons from the folder's `links:` |
| `![Alt](./img/shot.png)` | Image next to the file; click to zoom |
| `[Setup](./Setup.md)` | Link to another doc by file |

Run the draft post **Markdown cheat sheet** locally to see every option rendered.

## Content commands

| Command | What it does |
| --- | --- |
| `dart run tool/content.dart new-post "Title"` | New draft post |
| `dart run tool/content.dart new-doc <Folder> "Title"` | New doc page (creates the folder and `_category_.yaml` if needed) |
| `dart run tool/content.dart sync` | Registers every `content/` folder in `pubspec.yaml`. Flutter only bundles listed folders, so run it after adding folders by hand. |
| `dart run tool/content.dart check` | Finds missing images and invalid front matter |

## Customize

| To change | Edit |
| --- | --- |
| Name, links, nav items, hero text, home feature cards, footer | `lib/config/site_config.dart` |
| Colors / add a theme | `lib/theme/app_themes.dart` (each preset appears in the theme menu) |
| Fonts, button and card styling | `lib/theme/app_theme.dart` |
| Spacing, radii, breakpoints | `lib/theme/tokens.dart` |
| Home page section order | `HomePage.sections` in `lib/pages/home/home_page.dart` |
| About page text | `content/pages/about.md` |
| Your CV (Resume buttons) | Replace `web/files/DenizhanToprak_Resume.pdf` |

## Project layout

```
content/            Markdown: blog/, docs/, pages/
assets/images/      Logo and hero image
lib/
  config/           site_config.dart: everything about you
  content/          Markdown loading, front matter, custom blocks, search
  theme/            Palettes, ThemeData, tokens, theme switching
  router/           go_router routes
  widgets/          Reusable pieces: layout, cards, markdown renderer, search
  pages/            Home (sections/), docs, blog, about
tool/content.dart   Authoring CLI
test/               Content parsing tests
```

Packages: `go_router` (routing), `flutter_markdown_plus` (the maintained successor of the discontinued `flutter_markdown`), `flutter_highlight` (code), `google_fonts`, `flutter_animate`, `shared_preferences` (remembers the theme), `url_launcher`, `font_awesome_flutter` (brand icons).

## Deploy

```bash
flutter build web --release
```

Upload `build/web/`. The site uses clean URLs (`/docs/intro`), so the host must serve `index.html` for unknown paths:

- **GitHub Pages**: copy `build/web/index.html` to `build/web/404.html`. For a project page (`username.github.io/repo/`), build with `--base-href /repo/`.
- **Firebase Hosting / Netlify / Vercel**: add a rewrite of `**` to `/index.html`.
