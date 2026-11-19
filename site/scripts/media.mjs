// Prepares every file the site serves that isn't a page. Runs before `dev` and `build`.
//
// * Copies videos, icons, the logo, the CV and the like from ../web and ../assets into public/.
// * Converts every image under ../content to WebP at a few widths (GIFs stay animated),
//   and records each one's size in .media/manifest.json so pages can reserve the space
//   (no layout shift) and offer the browser the right width (srcset).
// * Bakes the soft effects that would otherwise cost on every frame: the hero
//   showreel's glow (one per clip, both themes) and the plugin carousel's blurred
//   backgrounds.
//
// Work is cached: an output newer than its source is left alone, so reruns are quick.
import { copyFile, mkdir, readdir, readFile, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { dirname, join, relative, extname, basename } from 'node:path';
import os from 'node:os';
import sharp from 'sharp';
import { IMAGE, convertImage, fresh, manifestPath, pub, repo } from './media-lib.mjs';

async function* walk(dir) {
  if (!existsSync(dir)) return;
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    if (entry.name.startsWith('.')) continue;
    const path = join(dir, entry.name);
    if (entry.isDirectory()) yield* walk(path);
    else yield path;
  }
}

async function copyTree(from, to, filter = () => true) {
  let n = 0;
  for await (const file of walk(from)) {
    if (!filter(file)) continue;
    const target = join(to, relative(from, file));
    if (await fresh(target, file)) continue;
    await mkdir(dirname(target), { recursive: true });
    await copyFile(file, target);
    n++;
  }
  return n;
}

/** Runs [tasks] a few at a time. */
async function pool(tasks, size = Math.max(2, Math.min(8, os.cpus().length))) {
  const results = [];
  let next = 0;
  await Promise.all(
    Array.from({ length: size }, async () => {
      while (next < tasks.length) {
        const i = next++;
        results[i] = await tasks[i]();
      }
    }),
  );
  return results;
}

// --- 1. Plain copies -------------------------------------------------------
let copied = 0;
copied += await copyTree(join(repo, 'web', 'videos'), join(pub, 'videos'), (f) => /\.(mp4|webm|jpg)$/i.test(f));
copied += await copyTree(join(repo, 'web', 'icons'), join(pub, 'icons'));
copied += await copyTree(join(repo, 'assets', 'images'), join(pub, 'brand'));
copied += await copyTree(join(repo, 'assets', 'files'), join(pub, 'files'));
for (const name of ['favicon.png', 'manifest.json', 'robots.txt']) {
  const from = join(repo, 'web', name);
  if (existsSync(from) && !(await fresh(join(pub, name), from))) {
    await copyFile(from, join(pub, name));
    copied++;
  }
}

// --- 2. Content images -----------------------------------------------------
const manifest = existsSync(manifestPath) ? JSON.parse(await readFile(manifestPath, 'utf8')) : {};
const seen = new Set();
const tasks = [];
for await (const file of walk(join(repo, 'content'))) {
  if (!IMAGE.test(file)) continue;
  const key = relative(repo, file).split('\\').join('/'); // content/docs/X/img/a.png
  seen.add(key);
  tasks.push(async () => {
    manifest[key] = await convertImage(key);
  });
}
await pool(tasks);
for (const key of Object.keys(manifest)) if (!seen.has(key)) delete manifest[key];

// --- 3. Baked effects --------------------------------------------------------

// The showreel glow, made the way unrealengine.com makes it: the clip's still
// stretched to cover a box (object-fit: cover), blurred by 80px, spreading
// 160px past the box on every side. Two boxes: the whole hero row (text and
// video side by side, wide screens) and the 16:9 video (smaller screens).
// Baked once here at 1/6 scale; the browser just scales the picture up, so
// the page never blurs anything while it scrolls. On a bright page dark parts
// fade out, so it reads as coloured light rather than a grey shadow.
const GLOW_VERSION = 'v2'; // bump to remake every glow after changing this code
const GLOW_SCALE = 1 / 6;
const GLOW_BLUR = 80;
const GLOW_SPREAD = 160;
const GLOW_BOXES = { wide: [1240, 470], video: [800, 450] };

async function bakeGlow(poster, [boxW, boxH], out, outBright) {
  const w = Math.round(boxW * GLOW_SCALE);
  const h = Math.round(boxH * GLOW_SCALE);
  const m = Math.round(GLOW_SPREAD * GLOW_SCALE);
  const sigma = GLOW_BLUR * GLOW_SCALE;
  // Colour: the edges carried outwards (so the blur doesn't drag black in) ...
  const color = await sharp(poster)
    .resize(w, h, { fit: 'cover' })
    .removeAlpha()
    .extend({ top: m, bottom: m, left: m, right: m, extendWith: 'copy' })
    .blur(sigma)
    .raw()
    .toBuffer({ resolveWithObject: true });
  // ... and how much shows: the box, blurred out to nothing at the edges.
  const box = await sharp({ create: { width: w, height: h, channels: 3, background: '#fff' } })
    .extend({ top: m, bottom: m, left: m, right: m, background: '#000' })
    .blur(sigma)
    .extractChannel(0)
    .raw()
    .toBuffer();
  const { width, height } = color.info;
  const rgba = Buffer.alloc(width * height * 4);
  const bright = Buffer.alloc(width * height * 4);
  for (let i = 0, j = 0; i < width * height; i++, j += 3) {
    const [r, g, b] = [color.data[j], color.data[j + 1], color.data[j + 2]];
    rgba.set([r, g, b, box[i]], i * 4);
    const luminance = (0.18 * r + 0.27 * g + 0.15 * b) / 255;
    bright.set([r, g, b, Math.round(box[i] * Math.min(1, luminance * 1.6))], i * 4);
  }
  const raw = { raw: { width, height, channels: 4 } };
  await sharp(rgba, raw).webp({ quality: 90, alphaQuality: 90 }).toFile(out);
  await sharp(bright, raw).webp({ quality: 90, alphaQuality: 90 }).toFile(outBright);
}

let glows = 0;
for await (const poster of walk(join(repo, 'web', 'videos'))) {
  if (!/\.jpg$/i.test(poster)) continue;
  const name = basename(poster, extname(poster));
  for (const [kind, box] of Object.entries(GLOW_BOXES)) {
    const out = join(pub, 'videos', `${name}.glow-${GLOW_VERSION}-${kind}.webp`);
    const outBright = join(pub, 'videos', `${name}.glow-${GLOW_VERSION}-${kind}-bright.webp`);
    if ((await fresh(out, poster)) && (await fresh(outBright, poster))) continue;
    await bakeGlow(poster, box, out, outBright);
    glows++;
  }
}

// The carousel's backgrounds: each plugin thumbnail as a tiny, heavily blurred
// picture that the browser just scales up.
let blurs = 0;
for await (const file of walk(join(repo, 'content', 'docs'))) {
  if (!/\/thumbnail\.(png|jpe?g|webp)$/i.test(file.split('\\').join('/'))) continue;
  const base = relative(join(repo, 'content'), file).split('\\').join('/').replace(/\.[^.]+$/, '');
  const out = join(pub, 'media', `${base}-blur.webp`);
  if (await fresh(out, file)) continue;
  await mkdir(dirname(out), { recursive: true });
  // Cut the edges after blurring: there the blur mixes in the empty space around the image.
  const small = await sharp(file).resize({ width: 96 }).blur(4).toBuffer({ resolveWithObject: true });
  const m = 8;
  await sharp(small.data)
    .extract({ left: m, top: m, width: small.info.width - 2 * m, height: small.info.height - 2 * m })
    .webp({ quality: 60 })
    .toFile(out);
  blurs++;
}

await mkdir(dirname(manifestPath), { recursive: true });
await writeFile(manifestPath, JSON.stringify(manifest, null, 1));
console.log(
  `media: ${Object.keys(manifest).length} content images, ${copied} files copied, ${glows} glows and ${blurs} blurred backgrounds made`,
);
