# Website

This website is built using [Docusaurus](https://docusaurus.io/), a modern static website generator.

### Installation

```
$ yarn
```

### Local Development

```
$ yarn start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

### Build

```
$ yarn build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

### Deployment

Using SSH:

```
$ USE_SSH=true yarn deploy
```

Not using SSH:

```
$ GIT_USER=<Your GitHub username> yarn deploy
```

If you are using GitHub pages for hosting, this command is a convenient way to build the website and push to the `gh-pages` branch.

### Portfolio

Portfolio projects live in the `portfolio/` directory, independently of the documentation in `docs/` and the personal blog in `blog/`. Add a Markdown file for each project; its title, description, and image appear on `/portfolio`, and the full Markdown content is available on its own shareable page.

Use this front matter as a starting point:

```md
---
slug: my-project
title: "My Project"
date: 2026-09-29
authors: [Denizhan]
tags: [Game Development]
image: /img/my-project-thumbnail.png
description: "A short summary displayed on the portfolio page."
---

Write the project story here. Use headings, images, links, and other Markdown
to explain the challenge, your approach, and the result.

<!-- truncate -->

Content after the truncate marker appears on the project detail page.
```
