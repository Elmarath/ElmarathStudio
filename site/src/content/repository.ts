// Loads every Markdown file under ../content once per build.
//
// * content/blog/*.md or content/blog/<folder>/index.md  → blog posts
// * content/docs/**                                      → the documentation tree
// * content/pages/*.md                                   → standalone pages (/about, /privacy-policy…)
// * content/work/*.md or content/work/<folder>/index.md  → portfolio case studies
//
// A port of the Flutter site's ContentRepository (lib/content/content_repository.dart):
// the same file layout, front matter and URLs.
import { readdirSync, readFileSync, existsSync } from 'node:fs';
import { join, relative, sep } from 'node:path';
// @ts-expect-error: plain JavaScript module shared with the media script.
import { repo } from '../../scripts/media-lib.mjs';
import { site } from '../config.ts';
import { FrontMatter, humanize, looseKey, parseYamlMap, plainText, slugify, formatDate } from './text.ts';
import { parseYoutube, type Youtube } from './markdown-source.ts';
import type { LegacyData } from '../scripts/legacy-core.ts';

/** The repository folder, which holds content/. */
export const repoRoot: string = repo;
const showDrafts = import.meta.env?.DEV ?? false;

export interface Author {
  id: string;
  name: string;
  title?: string;
  url?: string;
  imageUrl?: string;
}

export interface BlogPost {
  kind: 'post';
  slug: string;
  title: string;
  date: Date;
  authors: Author[];
  tags: string[];
  excerpt: string;
  body: string;
  /** Path of the .md file from the repository root (relative images resolve against it). */
  assetPath: string;
  /** Cover image: a `content/...` path or a URL. */
  image?: string;
  /** Looping clip shown instead of the cover image (`content/...` .mp4 made by `npm run video`). */
  video?: string;
  draft: boolean;
  /** `featured: true`: pinned as the blog's hero and badged. */
  featured: boolean;
  readingMinutes: number;
  route: string;
}

export interface DocPage {
  kind: 'page';
  id: string;
  title: string;
  /** Sidebar text (front matter `sidebar_label`, defaults to the title). */
  label: string;
  position: number;
  description?: string;
  body: string;
  assetPath: string;
  category?: DocCategory;
  route: string;
}

export interface DocCategory {
  kind: 'category';
  id: string;
  label: string;
  position: number;
  assetDir: string;
  description?: string;
  /** One-line pitch shown on cards. Falls back to the description. */
  summary?: string;
  /** `content/...` path or URL of the square thumbnail. */
  thumbnail?: string;
  /** Listed first in the home page carousel. */
  featured: boolean;
  /** `wip: true`: the docs are still being written; tagged "Work in progress". */
  wip: boolean;
  /** External links such as `fab` and `github`. */
  links: Record<string, string>;
  /** Old folder names (`aliases:` in _category_.yaml); links using them still resolve. */
  aliases: string[];
  children: DocNode[];
  parent?: DocCategory;
  /** An index.md inside the folder replaces the generated overview page. */
  indexPage?: DocPage;
  route: string;
}

export type DocNode = DocPage | DocCategory;

export interface MarkdownPage {
  kind: 'markdown';
  slug: string;
  title: string;
  description?: string;
  body: string;
  assetPath: string;
  route: string;
}

/** An impact number on a Work entry: "6" / "plugins on Fab". */
export interface WorkStat {
  value: string;
  label: string;
}

/** One thing built for a Work entry ("What I did"), with an optional image or clip. */
export interface WorkFeature {
  title: string;
  /** Markdown. */
  text: string;
  /** `content/...` image or .mp4 clip, or a URL. */
  media?: string;
  tags: string[];
}

/** A piece of code worth reading ("Code spotlight"). */
export interface WorkCode {
  title: string;
  /** Markdown: why it's interesting. */
  note?: string;
  lang: string;
  source: string;
}

export interface WorkMilestone {
  date: string;
  text: string;
}

export interface WorkQuote {
  text: string;
  author: string;
  role?: string;
}

/**
 * An entry on the Work page: a studio worked at, a personal project or a plugin.
 * Every one has a picture or clip, one main link and a 50 to 100 word summary;
 * the widgets (stats, features, code, milestones, quote) are optional.
 */
export interface CaseStudy {
  kind: 'work';
  slug: string;
  title: string;
  /** 50 to 100 words: what it is, what you did, why it matters. On cards and at the top of its page. */
  summary: string;
  /** Groups entries on the Work page: "Studio", "Personal project", "Plugin" (see `workGroups`). */
  workKind: string;
  role?: string;
  /** For studio work: who it was for (defaults to the title). */
  company?: string;
  /** The company's or project's logo (`content/...` image, ideally transparent): shown on the title card when there's no picture or clip. */
  logo?: string;
  location?: string;
  period?: string;
  team?: string;
  engine?: string;
  cover?: string;
  /** Looping clip shown instead of the cover, on cards and at the top (`content/...` .mp4 made by `npm run video`). */
  video?: string;
  /** A YouTube video, shown at the top instead of the cover. */
  reel?: Youtube;
  tech: string[];
  /** Results and facts worth seeing at a glance. */
  highlights: string[];
  stats: WorkStat[];
  features: WorkFeature[];
  code: WorkCode[];
  timeline: WorkMilestone[];
  quote?: WorkQuote;
  /** Buttons under the title, in order: label key → URL or site route. The first is the entry's main link. */
  links: Record<string, string>;
  order: number;
  draft: boolean;
  body: string;
  assetPath: string;
  route: string;
}

/** The Work page's groups, in order, by `kind:` (case-insensitive). Other kinds follow, as written. */
export const workGroups: { kinds: string[]; title: string; blurb: string }[] = [
  { kinds: ['studio', 'professional', 'experience'], title: 'Studios', blurb: 'Where I\'ve worked, and what I built there.' },
  { kinds: ['personal project', 'project', 'game', 'game jam'], title: 'Projects', blurb: 'Games and systems I build on my own, and with a team at game jams.' },
  { kinds: ['plugin', 'fab vendor'], title: 'Plugins', blurb: 'Unreal Engine tools, published with documentation.' },
];

export const pitch = (c: DocCategory) => c.summary ?? c.description ?? '';

/** Every page inside a folder, depth first, in sidebar order. */
export function allPages(c: DocCategory): DocPage[] {
  const out: DocPage[] = [];
  if (c.indexPage) out.push(c.indexPage);
  for (const child of c.children) {
    if (child.kind === 'page') out.push(child);
    else out.push(...allPages(child));
  }
  return out;
}

/** The top-level folder (the plugin) a page belongs to. */
export function rootCategory(page: DocPage): DocCategory | undefined {
  let c = page.category;
  while (c?.parent) c = c.parent;
  return c;
}

export const containsRoute = (c: DocCategory, route: string) => c.route === route || route.startsWith(`${c.route}/`);

export type SearchKind = 'doc' | 'post' | 'page' | 'work';

export interface SearchEntry {
  kind: SearchKind;
  title: string;
  /** Where it lives, e.g. the plugin name or the post date. */
  context: string;
  route: string;
  headings: string;
  text: string;
}

// --- Loading -----------------------------------------------------------------

const isMarkdown = (p: string) => p.endsWith('.md') || p.endsWith('.mdx');
const isCategoryFile = (p: string) => /\/_category_\.(json|ya?ml)$/.test(p);
const dirOf = (p: string) => p.slice(0, p.lastIndexOf('/'));
const nameOf = (p: string) => p.slice(p.lastIndexOf('/') + 1);

function readContentFiles(): Map<string, string> {
  const files = new Map<string, string>();
  const root = join(repoRoot, 'content');
  const walk = (dir: string) => {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      if (entry.name.startsWith('.')) continue;
      const path = join(dir, entry.name);
      if (entry.isDirectory()) walk(path);
      else {
        const key = relative(repoRoot, path).split(sep).join('/');
        if (isMarkdown(key) || isCategoryFile(key) || /^content\/blog\/authors\.ya?ml$/.test(key)) {
          files.set(key, readFileSync(path, 'utf8'));
        }
      }
    }
  };
  if (existsSync(root)) walk(root);
  return new Map([...files.entries()].sort(([a], [b]) => (a < b ? -1 : 1)));
}

/** Pulls a leading `# Title` out of the body, since pages render titles themselves. */
function extractTitle(body: string): [string | undefined, string] {
  const m = /^\s*#\s+(.+?)\s*#*\s*(\n|$)/.exec(body);
  if (!m) return [undefined, body];
  return [plainText(m[1]), body.slice(m.index + m[0].length)];
}

/** Front matter position, else a numeric file prefix (`02-setup.md`), else last. */
function position(value: unknown, name: string): number {
  if (typeof value === 'number') return value;
  const parsed = Number(value);
  if (value != null && Number.isFinite(parsed)) return parsed;
  const prefix = /^(\d+)[-_.\s]/.exec(name);
  return prefix ? Number(prefix[1]) : 1e6;
}

/**
 * Resolves an image path written in Markdown, relative to the file it's in.
 * Returns a URL unchanged, absolute paths under `content/`, and relative paths
 * next to the file.
 */
export function resolveAsset(sourcePath: string, src: string): string {
  const s = src.trim();
  if (/^(https?|data):/i.test(s)) return s;
  if (s.startsWith('/')) return `content${s}`;
  try {
    const resolved = new URL(s, `file:///${sourcePath}`).pathname.slice(1);
    return decodeURI(resolved);
  } catch {
    return `${dirOf(sourcePath)}/${s}`;
  }
}

function parseAuthors(files: Map<string, string>): Map<string, Author> {
  const entry = [...files.entries()].find(([k]) => k.startsWith('content/blog/authors.'));
  const authors = new Map<string, Author>();
  if (!entry) return authors;
  for (const [id, v] of Object.entries(parseYamlMap(entry[1]))) {
    if (!v || typeof v !== 'object') continue;
    const a = v as Record<string, unknown>;
    authors.set(id, {
      id,
      name: String(a.name ?? id),
      title: a.title == null ? undefined : String(a.title),
      url: a.url == null ? undefined : String(a.url),
      imageUrl: a.image_url == null ? undefined : String(a.image_url),
    });
  }
  return authors;
}

function parsePosts(files: Map<string, string>, authors: Map<string, Author>): BlogPost[] {
  const posts: BlogPost[] = [];
  for (const [path, raw] of files) {
    if (!path.startsWith('content/blog/') || !isMarkdown(path)) continue;
    const relativeParts = path.slice('content/blog/'.length).split('/');
    let baseName: string;
    if (relativeParts.length === 1) baseName = relativeParts[0].replace(/\.mdx?$/, '');
    else if (relativeParts.length === 2 && /^index\.mdx?$/.test(relativeParts[1])) baseName = relativeParts[0];
    else continue;

    const fm = FrontMatter.parse(raw);
    const draft = fm.flag('draft');
    if (draft && !showDrafts) continue;

    const nameMatch = /^(\d{4}-\d{2}-\d{2})[-_]?(.*)$/.exec(baseName);
    const parsedDate = new Date(fm.string('date') ?? nameMatch?.[1] ?? '2000-01-01');
    const date = Number.isNaN(parsedDate.getTime()) ? new Date('2000-01-01') : parsedDate;
    const [h1, body] = extractTitle(fm.body);
    const title = fm.string('title') ?? h1 ?? humanize(nameMatch?.[2] || baseName);
    const slug = slugify(fm.string('slug') ?? (nameMatch?.[2] ? nameMatch[2] : title));

    let excerpt = fm.string('description');
    if (excerpt == null) {
      const cut = body.indexOf('<!-- truncate -->');
      const intro = cut >= 0 ? body.slice(0, cut) : body.trim().split(/\n\s*\n/)[0];
      excerpt = plainText(intro);
    }
    if (excerpt.length > 220) excerpt = `${excerpt.slice(0, 217).trimEnd()}…`;

    const words = plainText(body).split(' ').length;
    const image = fm.string('image');
    const video = fm.string('video');
    posts.push({
      kind: 'post',
      slug,
      title,
      date,
      authors: fm.list('authors').map((id) => authors.get(id) ?? { id, name: id }),
      tags: fm.list('tags'),
      excerpt,
      body,
      assetPath: path,
      image: image == null ? undefined : resolveAsset(path, image),
      video: video == null ? undefined : resolveAsset(path, video),
      draft,
      featured: fm.flag('featured'),
      readingMinutes: Math.min(999, Math.max(1, Math.ceil(words / 220))),
      route: `/blog/${slug}`,
    });
  }
  return posts.sort((a, b) => b.date.getTime() - a.date.getTime());
}

function parseDocs(files: Map<string, string>): DocCategory {
  const rootDir = 'content/docs';
  const root: DocCategory = {
    kind: 'category', id: '', label: 'Docs', position: 0, assetDir: rootDir,
    featured: false, wip: false, links: {}, aliases: [], children: [], route: '/docs',
  };
  const byDir = new Map<string, DocCategory>([[rootDir, root]]);
  const meta = new Map<string, Record<string, unknown>>();
  for (const [k, v] of files) if (k.startsWith(`${rootDir}/`) && isCategoryFile(k)) meta.set(dirOf(k), parseYamlMap(v));

  const categoryFor = (dir: string): DocCategory => {
    const existing = byDir.get(dir);
    if (existing) return existing;
    const parent = categoryFor(dirOf(dir));
    const folder = nameOf(dir);
    const m = meta.get(dir) ?? {};
    const link = m.link as Record<string, unknown> | undefined;
    const thumbnail = m.thumbnail == null ? undefined : String(m.thumbnail);
    const links = m.links && typeof m.links === 'object' ? (m.links as Record<string, unknown>) : {};
    const id = [parent.id, slugify(folder)].filter(Boolean).join('/');
    const category: DocCategory = {
      kind: 'category',
      id,
      label: m.label == null ? humanize(folder) : String(m.label),
      position: position(m.position, folder),
      assetDir: dir,
      description: m.description != null ? String(m.description) : link?.description != null ? String(link.description) : undefined,
      summary: m.summary == null ? undefined : String(m.summary),
      thumbnail: thumbnail == null ? undefined : resolveAsset(`${dir}/_category_.yaml`, thumbnail),
      featured: m.featured === true,
      wip: m.wip === true,
      links: Object.fromEntries(Object.entries(links).map(([k, v]) => [k, String(v)])),
      aliases: Array.isArray(m.aliases) ? m.aliases.map(String) : [],
      children: [],
      parent: parent === root ? undefined : parent,
      route: `/docs/${id}`,
    };
    parent.children.push(category);
    byDir.set(dir, category);
    return category;
  };

  for (const [path, raw] of files) {
    if (!path.startsWith(`${rootDir}/`) || !isMarkdown(path)) continue;
    const dir = dirOf(path);
    const file = nameOf(path);
    const category = categoryFor(dir);
    const fm = FrontMatter.parse(raw);
    const [h1, body] = extractTitle(fm.body);
    const title = fm.string('title') ?? h1 ?? humanize(file);
    const isIndex = category !== root && /^(index|readme)\.mdx?$/i.test(file);
    // Like Docusaurus: `slug`, else `id`, else the file name sets the URL.
    const slug = slugify(fm.string('slug') ?? fm.string('id') ?? file);
    const id = isIndex ? category.id : [category.id, slug].filter(Boolean).join('/');
    const page: DocPage = {
      kind: 'page',
      id,
      title,
      label: fm.string('sidebar_label') ?? title,
      position: position(fm.data.sidebar_position, file),
      description: fm.string('description'),
      body,
      assetPath: path,
      category: category === root ? undefined : category,
      route: `/docs/${id}`,
    };
    if (isIndex) category.indexPage = page;
    else category.children.push(page);
  }

  const sortTree = (c: DocCategory) => {
    c.children.sort((a, b) => a.position - b.position || a.label.localeCompare(b.label));
    for (const child of c.children) if (child.kind === 'category') sortTree(child);
  };
  sortTree(root);
  return root;
}

function parsePages(files: Map<string, string>): Map<string, MarkdownPage> {
  const pages = new Map<string, MarkdownPage>();
  for (const [path, raw] of files) {
    if (!/^content\/pages\/[^/]+\.mdx?$/.test(path)) continue;
    const fm = FrontMatter.parse(raw);
    const [h1, body] = extractTitle(fm.body);
    const slug = slugify(fm.string('slug') ?? nameOf(path));
    pages.set(slug, {
      kind: 'markdown',
      slug,
      title: fm.string('title') ?? h1 ?? humanize(nameOf(path)),
      description: fm.string('description'),
      body,
      assetPath: path,
      route: `/${slug}`,
    });
  }
  return pages;
}

function parseWork(files: Map<string, string>): CaseStudy[] {
  const work: CaseStudy[] = [];
  for (const [path, raw] of files) {
    const m = /^content\/work\/(?:([^/]+)\.mdx?|([^/]+)\/index\.mdx?)$/.exec(path);
    if (!m) continue;
    const name = m[1] ?? m[2];
    if (name.startsWith('_')) continue; // notes and drafts kept out of the site
    const fm = FrontMatter.parse(raw);
    const draft = fm.flag('draft');
    if (draft && !showDrafts) continue;
    const [h1, body] = extractTitle(fm.body);
    const cover = fm.string('cover');
    const reel = fm.string('reel');
    const video = fm.string('video');
    const links = fm.data.links && typeof fm.data.links === 'object' ? (fm.data.links as Record<string, unknown>) : {};
    const slug = slugify(fm.string('slug') ?? name);
    const records = (key: string) => (Array.isArray(fm.data[key]) ? (fm.data[key] as unknown[]) : fm.data[key] ? [fm.data[key]] : [])
      .filter((r): r is Record<string, unknown> => !!r && typeof r === 'object');
    const text = (v: unknown) => (v == null ? '' : String(v).trim());
    const tags = (v: unknown) => (Array.isArray(v) ? v.map(String) : typeof v === 'string' ? v.split(',').map((t) => t.trim()).filter(Boolean) : []);
    const quote = records('quote')[0];
    const summary = fm.string('summary') ?? fm.string('tagline') ?? fm.string('description') ?? '';
    const words = summary.split(/\s+/).filter(Boolean).length;
    if (summary && (words < 40 || words > 110)) {
      console.warn(`[content] ${path}: the summary is ${words} words; 50 to 100 reads best on the cards.`);
    }
    work.push({
      kind: 'work',
      slug,
      title: fm.string('title') ?? h1 ?? humanize(name),
      summary,
      workKind: fm.string('kind') ?? 'Project',
      role: fm.string('role'),
      company: fm.string('company'),
      logo: fm.string('logo') == null ? undefined : resolveAsset(path, fm.string('logo')!),
      location: fm.string('location'),
      period: fm.string('period'),
      team: fm.string('team'),
      engine: fm.string('engine'),
      cover: cover == null ? undefined : resolveAsset(path, cover),
      video: video == null ? undefined : resolveAsset(path, video),
      reel: reel == null ? undefined : parseYoutube(reel),
      tech: fm.list('tech'),
      highlights: fm.list('highlights'),
      stats: records('stats').map((r) => ({ value: text(r.value), label: text(r.label) })).filter((r) => r.value),
      features: records('features')
        .map((r) => ({ title: text(r.title), text: text(r.text), media: r.media ? resolveAsset(path, text(r.media)) : undefined, tags: tags(r.tags) }))
        .filter((f) => f.title),
      code: records('code')
        .map((r) => ({ title: text(r.title), note: text(r.note) || undefined, lang: text(r.lang) || 'cpp', source: String(r.source ?? '').replace(/\s+$/, '') }))
        .filter((c) => c.source),
      timeline: records('timeline').map((r) => ({ date: text(r.date), text: text(r.text) })).filter((m) => m.text),
      quote: quote && quote.text ? { text: text(quote.text), author: text(quote.author), role: text(quote.role) || undefined } : undefined,
      // Site addresses are lower case; `/docs/My-Plugin` is accepted as written.
      links: Object.fromEntries(Object.entries(links).map(([k, v]) => [k, String(v).startsWith('/') ? String(v).toLowerCase() : String(v)])),
      order: fm.number('order') ?? 1e6,
      draft,
      body,
      assetPath: path,
      route: `/work/${slug}`,
    });
  }
  return work.sort((a, b) => a.order - b.order || a.title.localeCompare(b.title));
}

// --- The repository ------------------------------------------------------------

export class ContentRepository {
  readonly posts: BlogPost[];
  readonly docsRoot: DocCategory;
  readonly pages: Map<string, MarkdownPage>;
  /** Case studies in the order they're shown on the Work page (empty while `site.showWork` is off). */
  readonly work: CaseStudy[];
  /** All doc pages in sidebar order (used for previous/next links). */
  readonly docPages: DocPage[];
  readonly categories: DocCategory[];
  private readonly docsById = new Map<string, DocPage>();
  private readonly categoriesById = new Map<string, DocCategory>();

  constructor(files: Map<string, string>) {
    this.posts = parsePosts(files, parseAuthors(files));
    this.docsRoot = parseDocs(files);
    this.pages = parsePages(files);
    this.work = site.showWork ? parseWork(files) : [];
    this.docPages = allPages(this.docsRoot);
    for (const page of this.docPages) this.docsById.set(page.id, page);
    const cats: DocCategory[] = [];
    const index = (c: DocCategory) => {
      for (const child of c.children) {
        if (child.kind === 'category') {
          cats.push(child);
          this.categoriesById.set(child.id, child);
          index(child);
        }
      }
    };
    index(this.docsRoot);
    this.categories = cats;
  }

  get plugins(): DocCategory[] {
    return this.docsRoot.children.filter((c): c is DocCategory => c.kind === 'category');
  }

  /** The home page carousel: every plugin, those with `featured: true` first. */
  get spotlightPlugins(): DocCategory[] {
    return [...this.plugins.filter((c) => c.featured), ...this.plugins.filter((c) => !c.featured)];
  }

  doc(id: string) {
    return this.docsById.get(id);
  }
  category(id: string) {
    return this.categoriesById.get(id);
  }
  post(slug: string) {
    return this.posts.find((p) => p.slug === slug);
  }
  caseStudy(slug: string) {
    return this.work.find((w) => w.slug === slug);
  }

  /** Tags, most used first. */
  get tags(): string[] {
    const counts = new Map<string, number>();
    for (const p of this.posts) for (const t of p.tags) counts.set(t, (counts.get(t) ?? 0) + 1);
    return [...counts.keys()].sort((a, b) => counts.get(b)! - counts.get(a)!);
  }

  get searchIndex(): SearchEntry[] {
    return [
      ...this.docPages.map((d) => ({
        kind: 'doc' as const,
        title: d.title,
        context: rootCategory(d)?.label ?? 'Docs',
        route: d.route,
        headings: headingsOf(d.body).join(' · '),
        text: plainText(d.body),
      })),
      ...this.posts.map((p) => ({
        kind: 'post' as const,
        title: p.title,
        context: `Blog · ${formatDate(p.date)}`,
        route: p.route,
        headings: p.tags.join(' '),
        text: plainText(p.body),
      })),
      ...this.work.map((w) => ({
        kind: 'work' as const,
        title: w.title,
        context: `Work · ${w.workKind}`,
        route: w.route,
        headings: [...w.tech, ...headingsOf(w.body)].join(' · '),
        text: plainText(`${w.summary} ${w.features.map((f) => `${f.title} ${f.text}`).join(' ')} ${w.body}`),
      })),
      ...[...this.pages.values()].map((p) => ({
        kind: 'page' as const,
        title: p.title,
        context: 'Page',
        route: p.route,
        headings: '',
        text: plainText(p.body),
      })),
    ];
  }

  /** Every page on the site. */
  get routes(): string[] {
    return [
      '/',
      '/docs',
      '/blog',
      ...this.tags.map((t) => `/blog/tag/${slugify(t)}`),
      '/about',
      '/cv',
      ...(site.showWork ? ['/work', ...this.work.map((w) => w.route)] : []),
      ...this.docPages.map((d) => d.route),
      ...this.categories.map((c) => c.route),
      ...this.posts.map((p) => p.route),
      ...[...this.pages.keys()].map((slug) => `/${slug}`),
    ];
  }

  /** Old folder name (slug) → the folder's current name, from `aliases:` in _category_.yaml. */
  get folderAliases(): Record<string, string> {
    const out: Record<string, string> = {};
    for (const c of this.categories) for (const alias of c.aliases) out[slugify(alias)] = c.id.split('/').at(-1)!;
    return out;
  }

  /** Category label slug and folder slug → its route, for Docusaurus' `/docs/category/<x>` overviews. */
  get categoryKeys(): Record<string, string> {
    const out: Record<string, string> = {};
    for (const c of this.categories) {
      out[c.id.split('/').at(-1)!] ??= c.route;
      out[slugify(c.label)] ??= c.route;
    }
    return out;
  }

  /** What the old-address matcher (src/scripts/legacy-core.ts) needs to know. */
  get legacyData(): LegacyData {
    return {
      routes: this.routes,
      moved: site.movedPages,
      folderAliases: this.folderAliases,
      categoryKeys: this.categoryKeys,
      tags: this.tags.map((t) => slugify(t)),
    };
  }

  /**
   * Maps a Markdown link to a route on this site, or null if it's external.
   * Understands site routes (`/docs/intro`), Docusaurus-style paths
   * (`/docs/Easy-Ability-Set-System/AbilitySets`) and relative file links
   * (`./Setup.md`, `../other-plugin/overview.md`).
   */
  internalRoute(href: string, sourcePath: string): string | null {
    let link = href.trim();
    if (link.length === 0 || /^[a-z][a-z0-9+.-]*:/i.test(link)) return null;
    let fragment = '';
    const hash = link.indexOf('#');
    if (hash >= 0) {
      fragment = link.slice(hash);
      link = link.slice(0, hash);
    }
    if (link.length === 0) return fragment;

    if (!link.startsWith('/')) {
      const asset = resolveAsset(sourcePath, link);
      link = asset.startsWith('content/pages/') ? asset.slice('content/pages'.length) : asset.slice('content'.length);
    }
    const segments = link.split('/').filter(Boolean);
    if (segments.length === 0) return `/${fragment}`;
    const section = segments[0].toLowerCase();
    const rest = segments.slice(1).map((s) => slugify(s)).filter((s) => s && s !== 'index');
    if (section === 'docs' || section === 'blog') {
      if (section === 'blog' && rest.length > 0) {
        const last = segments.at(-1)!;
        const post = this.posts.find((p) => p.slug === rest.at(-1) || p.assetPath.includes(last));
        if (post) return `${post.route}${fragment}`;
      }
      return `/${[section, ...rest].join('/')}${fragment}`;
    }
    return `/${segments.map((s) => slugify(s)).join('/')}${fragment}`;
  }
}

/** The h2/h3 headings of a Markdown body, as plain text. */
function headingsOf(body: string): string[] {
  const out: string[] = [];
  let fence = false;
  for (const line of body.split('\n')) {
    if (/^\s*(```|~~~)/.test(line)) fence = !fence;
    if (fence) continue;
    const m = /^(#{2,3})\s+(.+?)\s*#*\s*$/.exec(line);
    if (m) out.push(plainText(m[2]));
  }
  return out;
}

let instance: ContentRepository | undefined;

/** The site's content, read once per build (and on each request in dev, so edits show up). */
export function content(): ContentRepository {
  if (showDrafts) return new ContentRepository(readContentFiles());
  return (instance ??= new ContentRepository(readContentFiles()));
}

export { formatDate, looseKey };
