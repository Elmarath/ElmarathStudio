// Starts a new blog post, doc page or case study from a template.
//
//   npm run new-post -- "My post title" [--tags "Unreal, Devlog"] [--folder]
//   npm run new-doc  -- <Plugin-Folder> "Page title"
//   npm run new-work -- "Project name"
//
// Files go into ../content; the site picks them up on its own (no list to update).
import { existsSync, mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const content = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'content');
const [kind, ...args] = process.argv.slice(2);
const slug = (s) => s.toLowerCase().replace(/['’]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
const yamlString = (s) => JSON.stringify(s);
const today = () => new Date().toISOString().slice(0, 10);
const option = (name) => {
  const i = args.indexOf(name);
  if (i < 0) return undefined;
  const value = args[i + 1];
  args.splice(i, 2);
  return value;
};
const flag = (name) => {
  const i = args.indexOf(name);
  if (i >= 0) args.splice(i, 1);
  return i >= 0;
};
const create = (file, text) => {
  if (existsSync(file)) {
    console.error(`${file} already exists.`);
    process.exit(1);
  }
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, text);
  console.log(`Created ${file}`);
};

if (kind === 'post') {
  const tags = option('--tags') ?? '';
  const folder = flag('--folder');
  const title = args.join(' ');
  if (!title) usage();
  const name = `${today()}-${slug(title)}`;
  create(
    folder ? join(content, 'blog', name, 'index.md') : join(content, 'blog', `${name}.md`),
    `---
title: ${yamlString(title)}
authors: [denizhan]
tags: [${tags.split(',').map((t) => t.trim()).filter(Boolean).join(', ')}]
description: One or two sentences shown on the post card.
# image: cover.jpg   # optional cover, relative to this file
# featured: true     # pin as the big post at the top of the blog
draft: true          # visible only while running locally (npm run dev); delete this line to publish
---

The first paragraph is the hook.

<!-- truncate -->

## First section

Write here. Images go next to the file: ![Alt text](./my-image.png)
`,
  );
} else if (kind === 'doc') {
  const [folderName, ...words] = args;
  const title = words.join(' ');
  if (!folderName || !title) usage();
  const dir = join(content, 'docs', folderName);
  if (!existsSync(dir)) {
    create(
      join(dir, '_category_.yaml'),
      `label: ${yamlString(folderName.replace(/-/g, ' '))}
summary: One sentence about this plugin, shown on cards.
# description: Longer text for the plugin's overview page.
# thumbnail: thumbnail.png   # square image in this folder
# featured: true             # show first in the home page carousel
# links:
#   fab: https://www.fab.com/listings/...
#   github: https://github.com/...
`,
    );
  }
  const existing = readdirSync(dir).filter((f) => f.endsWith('.md')).length;
  const fileName = title.split(/\s+/).map((w) => w[0].toUpperCase() + w.slice(1)).join('-');
  create(
    join(dir, `${fileName}.md`),
    `---
sidebar_position: ${existing + 1}
---

# ${title}

${existing === 0 ? '::plugin-links\n\n' : ''}Introduce the page in a sentence or two.

## Section

:::tip
Callouts: note, tip, info, warning, danger.
:::
`,
  );
} else if (kind === 'work') {
  const title = args.join(' ');
  if (!title) usage();
  create(
    join(content, 'work', slug(title), 'index.md'),
    `---
title: ${yamlString(title)}
# One sentence: what it is and why someone should care.
tagline: A short pitch shown under the title and on the Work page.
# Groups projects on the Work page, e.g. Professional, Personal project, Plugin.
kind: Personal project
role: "Solo developer: gameplay, AI, UI and tools"
period: 2025 – present
# team: Solo
# engine: Unreal Engine 5.5
# The video at the top. Without one, the cover image is shown instead.
# reel: https://youtu.be/...
# cover: cover.jpg
tech: [C++, Gameplay Ability System, State Trees]
# Facts and results worth seeing at a glance. Concrete beats vague.
highlights:
  - Something you shipped, measured or made possible
# Buttons under the title; the first one is the main one.
links:
  # reel: https://youtu.be/...
  # github: https://github.com/...
  # docs: /docs/...
order: 10          # lower comes first on the Work page
draft: true        # visible only while running locally; delete this line to publish
---

## Overview

Two or three sentences: what the project is, who it's for, and what you were responsible for.

## The challenge

What made this hard? Constraints, scale, multiplayer, performance, team or deadline.

## My approach

The key decisions and why you made them. A diagram or a screenshot helps here: put the image
next to this file and add it with Markdown's image syntax.

## Systems

### First system

What it does, how it works, and one detail you're proud of. Show it with a gif or a clip.

## Results

What came out of it: shipped, reused, faster, fewer bugs, positive reviews.

## What I learned

What you'd keep, and what you'd do differently next time.
`,
  );
} else {
  usage();
}

function usage() {
  console.log(`Usage:
  npm run new-post -- "Title" [--tags "A, B"] [--folder]
  npm run new-doc  -- <Plugin-Folder> "Title"
  npm run new-work -- "Project name"`);
  process.exit(1);
}
