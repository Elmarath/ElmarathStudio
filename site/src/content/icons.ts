// Inline SVG icons, read from the icon packages at build time. Pages carry the
// markup itself: no icon font to download, nothing that pops in late.
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { faDiscord, faGithub, faLinkedin, faXTwitter, faYoutube } from '@fortawesome/free-brands-svg-icons';
import type { IconName } from '../config.ts';

const require = createRequire(import.meta.url);
const lucideDir = require.resolve('lucide-static/package.json').replace(/package\.json$/, 'icons/');

/** Site icon name → Lucide icon file. */
const lucide: Partial<Record<IconName, string>> = {
  mail: 'mail',
  'thumbs-up': 'thumbs-up',
  'thumbs-down': 'thumbs-down',
  send: 'send',
  store: 'store',
  doc: 'file-text',
  book: 'book-open',
  search: 'search',
  palette: 'palette',
  menu: 'menu',
  close: 'x',
  'arrow-right': 'arrow-right',
  'arrow-left': 'arrow-left',
  'chevron-right': 'chevron-right',
  play: 'play',
  pause: 'pause',
  download: 'download',
  external: 'external-link',
  copy: 'copy',
  check: 'check',
  rocket: 'rocket',
  folder: 'folder',
  file: 'file-text',
  puzzle: 'puzzle',
  grid: 'layout-grid',
  edit: 'pencil',
  construction: 'construction',
  star: 'star',
  note: 'sticky-note',
  tip: 'lightbulb',
  info: 'info',
  warning: 'triangle-alert',
  danger: 'flame',
  article: 'newspaper',
  work: 'briefcase',
  'check-circle': 'circle-check',
  globe: 'globe',
  gamepad: 'gamepad-2',
  code: 'code',
  'map-pin': 'map-pin',
  calendar: 'calendar',
  users: 'users',
  'trending-up': 'trending-up',
  cpu: 'cpu',
  building: 'building-2',
  sparkles: 'sparkles',
  quote: 'quote',
  milestone: 'milestone',
  layers: 'layers',
};

const brands: Partial<Record<IconName, { icon: [number, number, unknown, unknown, string | string[]] }>> = {
  github: faGithub,
  linkedin: faLinkedin,
  discord: faDiscord,
  youtube: faYoutube,
  x: faXTwitter,
};

const cache = new Map<string, string>();

/** The icon as an `<svg>` string, sized with CSS (1em by default). */
export function iconSvg(name: IconName, { size, label }: { size?: number; label?: string } = {}): string {
  const key = `${name}|${size ?? ''}|${label ?? ''}`;
  const hit = cache.get(key);
  if (hit) return hit;
  const dims = size ? ` width="${size}" height="${size}"` : '';
  const a11y = label ? ` role="img" aria-label="${label}"` : ' aria-hidden="true" focusable="false"';
  let svg: string;
  const brand = brands[name];
  if (brand) {
    const [w, h, , , path] = brand.icon;
    const d = Array.isArray(path) ? path.join(' ') : path;
    svg = `<svg class="icon" viewBox="0 0 ${w} ${h}"${dims}${a11y} fill="currentColor"><path d="${d}"/></svg>`;
  } else {
    const file = lucide[name];
    if (!file) throw new Error(`Unknown icon: ${name}`);
    const inner = readFileSync(`${lucideDir}${file}.svg`, 'utf8')
      .replace(/<!--[\s\S]*?-->/g, '')
      .replace(/^[\s\S]*?<svg[^>]*>/, '')
      .replace(/<\/svg>\s*$/, '')
      .replace(/\s+/g, ' ')
      .trim();
    svg =
      `<svg class="icon" viewBox="0 0 24 24"${dims}${a11y} fill="none" stroke="currentColor" ` +
      `stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${inner}</svg>`;
  }
  cache.set(key, svg);
  return svg;
}
