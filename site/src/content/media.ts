// Content images, as converted by scripts/media.mjs: where each WebP variant
// lives and how big the image is, so pages can reserve its space and let the
// browser pick the right width.
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
// @ts-expect-error: plain JavaScript module shared with the media script.
import { convertImage, manifestPath } from '../../scripts/media-lib.mjs';
import { isExternal } from './text.ts';

export interface ImageInfo {
  src: string;
  srcset?: string;
  width?: number;
  height?: number;
  animated?: boolean;
}

interface Entry {
  width: number;
  height: number;
  animated: boolean;
  variants: { url: string; width: number }[];
}

let manifest: Record<string, Entry> | undefined;
const load = () =>
  (manifest ??= existsSync(manifestPath) ? JSON.parse(readFileSync(manifestPath, 'utf8')) : {}) as Record<string, Entry>;

/**
 * An image referenced from content: a URL, a `content/...` file (converted to
 * WebP), or an `assets/...` file (copied into public/ as is).
 *
 * [displayWidth] is the widest it's shown, in CSS pixels: `src` is the variant
 * for that width at 2× density, and `srcset` offers all of them.
 */
export async function image(key: string, displayWidth = 800): Promise<ImageInfo | null> {
  if (isExternal(key)) return { src: key };
  if (key.startsWith('assets/images/')) return { src: `/brand/${key.slice('assets/images/'.length)}` };
  if (key.startsWith('assets/files/')) return { src: `/files/${key.slice('assets/files/'.length)}` };
  if (!key.startsWith('content/')) return null;

  const all = load();
  let entry = all[key];
  if (!entry) {
    // Added since `npm run media` last ran (e.g. while the dev server is up): convert it now.
    try {
      entry = await convertImage(key);
      all[key] = entry;
      writeFileSync(manifestPath, JSON.stringify(all, null, 1));
    } catch {
      console.warn(`[content] missing image: ${key}`);
      return null;
    }
  }
  const wanted = displayWidth * 2;
  const pick = entry.variants.find((v) => v.width >= wanted) ?? entry.variants.at(-1)!;
  return {
    src: pick.url,
    srcset: entry.variants.length > 1 ? entry.variants.map((v) => `${v.url} ${v.width}w`).join(', ') : undefined,
    width: entry.width,
    height: entry.height,
    animated: entry.animated,
  };
}

/** The small pre-blurred copy of a plugin thumbnail, for the carousel background. */
export function blurredThumbnail(key: string): string | null {
  if (!key.startsWith('content/')) return null;
  return `/media/${key.slice('content/'.length).replace(/\.[^.]+$/, '')}-blur.webp`;
}
