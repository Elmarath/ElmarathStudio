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
// shrunk to 128×72, blurred into a wash of its colours (80px on a 978px video
// there) that fades out at twice the blur. On a bright page dark parts fade
// out, so it reads as coloured light rather than a grey shadow.
const GLOW_W = 128;
const GLOW_H = 72;
const GLOW_MARGIN = 22;
const GLOW_SIGMA = (GLOW_W * 80) / 978;
let glows = 0;
for await (const poster of walk(join(repo, 'web', 'videos'))) {
  if (!/\.jpg$/i.test(poster)) continue;
  const name = basename(poster, extname(poster));
  const dark = join(pub, 'videos', `${name}-glow.webp`);
  const bright = join(pub, 'videos', `${name}-glow-bright.webp`);
  if ((await fresh(dark, poster)) && (await fresh(bright, poster))) continue;
  const blurred = await sharp(poster)
    .resize(GLOW_W, GLOW_H, { fit: 'cover' })
    .ensureAlpha()
    .extend({ top: GLOW_MARGIN, bottom: GLOW_MARGIN, left: GLOW_MARGIN, right: GLOW_MARGIN, background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .blur(GLOW_SIGMA)
    .raw()
    .toBuffer({ resolveWithObject: true });
  const { data, info } = blurred;
  await sharp(data, { raw: info }).webp({ quality: 80, alphaQuality: 80 }).toFile(dark);
  const light = Buffer.from(data);
  for (let i = 0; i < light.length; i += 4) {
    const luminance = (0.18 * light[i] + 0.27 * light[i + 1] + 0.15 * light[i + 2]) / 255;
    light[i + 3] = Math.round(light[i + 3] * Math.min(1, luminance * 1.6));
  }
  await sharp(light, { raw: info }).webp({ quality: 80, alphaQuality: 80 }).toFile(bright);
  glows++;
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
