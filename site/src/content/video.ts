// Looping clips from content (made by `npm run video`): silent, always
// playing, and looping. src/scripts/loop-video.ts plays each one while it's on
// screen and pauses it once it's scrolled away, so a page full of them stays light.
import { existsSync } from 'node:fs';
import { join } from 'node:path';
// @ts-expect-error: plain JavaScript module shared with the media script.
import { VIDEO, copyVideo, mediaUrl, repo } from '../../scripts/media-lib.mjs';
import { image, type ImageInfo } from './media.ts';
import { escapeHtml } from './text.ts';

export interface LoopVideo {
  /** The H.264 file, which every browser plays. */
  src: string;
  /** The smaller AV1 copy, when there is one. */
  av1?: string;
  poster?: ImageInfo;
}

export const isVideo = (key: string) => VIDEO.test(key);

/**
 * The clip at `content/...` path [key] (with its AV1 copy and poster beside it),
 * or null when there's no such file. [displayWidth] picks the poster's width.
 */
export async function loopVideo(key: string, displayWidth = 800): Promise<LoopVideo | null> {
  if (!key.startsWith('content/') || !isVideo(key) || !existsSync(join(repo, key))) {
    console.warn(`[content] missing video: ${key}`);
    return null;
  }
  // Added since `npm run media` last ran (e.g. while the dev server is up): copy it now.
  const av1Key = key.replace(/\.mp4$/i, '.av1.mp4');
  const hasAv1 = existsSync(join(repo, av1Key));
  await copyVideo(key);
  if (hasAv1) await copyVideo(av1Key);
  const posterKey = key.replace(/\.mp4$/i, '.jpg');
  const poster = existsSync(join(repo, posterKey)) ? ((await image(posterKey, displayWidth)) ?? undefined) : undefined;
  return { src: mediaUrl(key), av1: hasAv1 ? mediaUrl(av1Key) : undefined, poster };
}

/**
 * The `<video>` for [video]. With a [label] it's announced to screen readers
 * (as an image is, by its alt text); without one it's decoration.
 */
export function loopVideoHtml(video: LoopVideo, { label, className = '' }: { label?: string; className?: string } = {}): string {
  const p = video.poster;
  const attrs = [
    `class="loop-video${className ? ` ${className}` : ''}"`,
    'data-loop muted loop playsinline preload="none"',
    'disablepictureinpicture disableremoteplayback',
    p ? `poster="${p.src}"` : '',
    p?.width ? `width="${p.width}" height="${p.height}"` : '',
    label ? `role="img" aria-label="${escapeHtml(label)}"` : 'aria-hidden="true"',
    'tabindex="-1"',
  ].filter(Boolean);
  return (
    `<video ${attrs.join(' ')}>` +
    (video.av1 ? `<source src="${video.av1}" type='video/mp4; codecs="av01.0.08M.08"'>` : '') +
    `<source src="${video.src}" type="video/mp4"></video>`
  );
}
