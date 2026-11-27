// Text helpers shared by the content loader, the pages and the browser scripts.
// They match the Flutter site's (lib/content/text_utils.dart) exactly, so every
// URL and heading anchor stays the same.
import { parse as parseYaml } from 'yaml';

/**
 * Turns a file name, folder name or heading into a URL-safe id.
 * `Easy-Trace-Trail-System` → `easy-trace-trail-system`, `AbilitySets.md` →
 * `ability-sets`, `02-setup` → `setup`.
 */
export function slugify(input: string, { stripNumberPrefix = true } = {}): string {
  let s = input;
  try {
    s = decodeURIComponent(s);
  } catch {}
  s = s.replace(/\.(md|mdx)$/i, '');
  if (stripNumberPrefix) s = s.replace(/^\d+[-_.\s]+(?=\S)/, '');
  s = s.replace(/([a-z0-9])([A-Z])/g, '$1-$2');
  s = s.replace(/([A-Z]+)([A-Z][a-z])/g, '$1-$2');
  s = s.toLowerCase().replace(/['’]/g, '');
  s = s.replace(/[^a-z0-9]+/g, '-');
  return s.replace(/^-+|-+$/g, '');
}

/** `Easy-Trace-Trail-System` → `Easy Trace Trail System`. */
export function humanize(input: string): string {
  let s = input.replace(/\.(md|mdx)$/, '');
  s = s.replace(/^\d+[-_.\s]+(?=\S)/, '');
  s = s.replace(/([a-z0-9])([A-Z])/g, '$1 $2');
  s = s.replace(/[-_]+/g, ' ').trim();
  return s.length === 0 ? input : s[0].toUpperCase() + s.slice(1);
}

/** Strips Markdown syntax to get readable text (for excerpts, search and the TOC). */
export function plainText(markdown: string): string {
  let s = markdown;
  s = s.replace(/<!--[\s\S]*?-->/g, ' ');
  s = s.replace(/```[\s\S]*?```/g, ' ');
  s = s.replace(/!\[([^\]]*)\]\([^)]*\)/g, '');
  s = s.replace(/\[([^\]]*)\]\([^)]*\)/g, '$1');
  s = s.replace(/<[^>]+>/g, '');
  s = s.replace(/^\s{0,3}(#{1,6}|>|[-*+]|\d+\.)\s+/gm, '');
  s = s.replace(/^:{2,}.*$/gm, '');
  s = s.replace(/[*_`~|]/g, '');
  return s.replace(/\s+/g, ' ').trim();
}

/** A Markdown file split into its YAML front matter and body. */
export class FrontMatter {
  readonly data: Record<string, unknown>;
  readonly body: string;

  constructor(data: Record<string, unknown>, body: string) {
    this.data = data;
    this.body = body;
  }

  static parse(raw: string): FrontMatter {
    const text = raw.replace(/\r\n/g, '\n');
    const m = /^---[ \t]*\n([\s\S]*?)\n---[ \t]*(\n|$)/.exec(text);
    if (!m) return new FrontMatter({}, text);
    return new FrontMatter(parseYamlMap(m[1]), text.slice(m.index + m[0].length));
  }

  string(key: string): string | undefined {
    const v = this.data[key];
    if (v == null) return undefined;
    const s = String(v).trim();
    return s.length === 0 ? undefined : s;
  }

  number(key: string): number | undefined {
    const v = this.data[key];
    if (typeof v === 'number') return v;
    if (v == null) return undefined;
    const n = Number(v);
    return Number.isFinite(n) ? n : undefined;
  }

  flag(key: string): boolean {
    const v = this.data[key];
    return v === true || String(v) === 'true';
  }

  list(key: string): string[] {
    const v = this.data[key];
    // An unquoted item with ": " in it ("No limit: any depth") reads as a
    // one-entry map in YAML; turn it back into the sentence that was written.
    if (Array.isArray(v)) {
      return v.map((e) =>
        e && typeof e === 'object'
          ? Object.entries(e)
              .map(([k, x]) => `${k}: ${x}`)
              .join(', ')
          : String(e),
      );
    }
    if (typeof v === 'string') return v.split(',').map((e) => e.trim()).filter(Boolean);
    return [];
  }
}

/** Parses YAML (or JSON, which is valid YAML) into plain objects. */
export function parseYamlMap(source: string): Record<string, unknown> {
  if (source.trim().length === 0) return {};
  const value = parseYaml(source);
  return value && typeof value === 'object' && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/** `Nov 10, 2026`. Dates are calendar dates (no time zone shifts). */
export function formatDate(date: Date): string {
  return `${months[date.getUTCMonth()]} ${date.getUTCDate()}, ${date.getUTCFullYear()}`;
}

export function escapeHtml(s: string): string {
  return s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!);
}

/** Letters and digits only, lowercased: `/docs/Decide%20Montages` and `/docs/decide-montages` look the same. */
export function looseKey(path: string): string {
  let s = path;
  try {
    s = decodeURI(s);
  } catch {}
  return s.toLowerCase().replace(/[^a-z0-9]/g, '');
}

export const isExternal = (href: string) => /^[a-z][a-z0-9+.-]*:/i.test(href);
