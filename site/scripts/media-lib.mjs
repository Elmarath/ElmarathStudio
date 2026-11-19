// Image conversion shared by scripts/media.mjs (everything, before a build) and
// the content loader (one new image at a time, while `npm run dev` is running).
import { mkdir, stat } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';

// The site folder: where the command runs (npm scripts run here), or next to
// this file. (Not only next to this file: when the site is built, this code is
// bundled into another folder.)
export const site = existsSync(join(process.cwd(), 'astro.config.mjs'))
  ? process.cwd()
  : join(dirname(fileURLToPath(import.meta.url)), '..');
export const repo = join(site, '..');
export const pub = join(site, 'public');
export const manifestPath = join(site, '.media', 'manifest.json');

/** Widths offered for content images; each image gets those up to its own width. */
export const WIDTHS = [480, 960, 1600];
export const IMAGE = /\.(png|jpe?g|webp|gif)$/i;

export async function fresh(output, source) {
  if (!existsSync(output)) return false;
  return (await stat(output)).mtimeMs >= (await stat(source)).mtimeMs;
}

/**
 * Converts `content/...` image [key] to WebP at the widths that fit it (a GIF
 * stays animated, at one width) into public/media, and returns its manifest
 * entry: its size and the variants made.
 */
export async function convertImage(key) {
  const file = join(repo, key);
  const base = key.slice('content/'.length).replace(/\.[^.]+$/, '');
  const animated = /\.gif$/i.test(file);
  const meta = await sharp(file, { animated }).metadata();
  const width = meta.width;
  const height = animated ? (meta.pageHeight ?? meta.height) : meta.height;
  const widths = animated ? [Math.min(width, 960)] : [...WIDTHS.filter((w) => w < width), Math.min(width, WIDTHS.at(-1))];
  const variants = [];
  for (const w of [...new Set(widths)]) {
    const url = `/media/${base}-${w}.webp`;
    const out = join(pub, url);
    if (!(await fresh(out, file))) {
      await mkdir(dirname(out), { recursive: true });
      await sharp(file, { animated })
        .resize({ width: w, withoutEnlargement: true })
        .webp({ quality: animated ? 70 : 78, effort: 4 })
        .toFile(out);
    }
    variants.push({ url, width: w });
  }
  return { width, height, animated, variants };
}
