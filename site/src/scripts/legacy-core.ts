// Where an old address (the previous Docusaurus site, or a link with different
// letter case, spaces or dashes) lives now. Used at build time to write
// permanent redirects for every known old address, and by the 404 page for
// anything else. No imports from the site, so it runs in the browser as is.

export interface LegacyData {
  /** Every page on the site. */
  routes: string[];
  /** Old addresses that moved somewhere else entirely (`movedPages` in src/config.ts). */
  moved: Record<string, string>;
  /** Old folder name (slug) → its current name, from `aliases:` in _category_.yaml. */
  folderAliases: Record<string, string>;
  /** Docs folder label or name (slug) → its route, for Docusaurus' /docs/category/<x>. */
  categoryKeys: Record<string, string>;
  /** Blog tag slugs. */
  tags: string[];
}

/** Letters and digits only, lowercased: `/docs/Decide%20Montages` and `/docs/decide-montages` look the same. */
export function looseKey(path: string): string {
  let s = path;
  try {
    s = decodeURI(s);
  } catch {}
  return s.toLowerCase().replace(/[^a-z0-9]/g, '');
}

/** The same as the site's slugify (src/content/text.ts). */
export function slug(input: string): string {
  let s = input;
  try {
    s = decodeURIComponent(s);
  } catch {}
  s = s.replace(/\.(md|mdx)$/i, '').replace(/^\d+[-_.\s]+(?=\S)/, '');
  s = s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').replace(/([A-Z]+)([A-Z][a-z])/g, '$1-$2');
  return s.toLowerCase().replace(/['’]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

/**
 * The page [rawPath] stands for today, or null when it's already a page or
 * nothing matches. [hash] (with its `#`) is kept.
 */
export function legacyRoute(rawPath: string, data: LegacyData, hash = ''): string | null {
  const routes = new Set(data.routes);
  let path = rawPath;
  try {
    path = decodeURI(path);
  } catch {}
  path = path.replace(/\.html$/, '');
  if (path.length > 1) path = path.replace(/\/+$/, '');
  if (routes.has(path)) return null;

  const key = looseKey(path);
  for (const [from, to] of Object.entries(data.moved)) if (looseKey(from) === key) return to;

  const segments = path.split('/').filter(Boolean);
  const section = segments[0]?.toLowerCase();
  if (section === 'blog' && segments.length >= 3 && /^tags?$/i.test(segments[1])) {
    const tag = slug(segments[2]);
    return data.tags.includes(tag) ? `/blog/tag/${tag}` : '/blog';
  }
  if (section === 'docs' && segments.length === 3 && segments[1].toLowerCase() === 'category') {
    const match = data.categoryKeys[slug(segments[2])];
    if (match) return match;
  }
  const renamed = segments.map((s) => data.folderAliases[slug(s)] ?? s);
  const wanted = looseKey(`/${renamed.join('/')}`);
  const match = data.routes.find((r) => looseKey(r) === wanted);
  return match && match !== rawPath ? `${match}${hash}` : null;
}
