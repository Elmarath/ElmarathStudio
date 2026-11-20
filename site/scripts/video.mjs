// Turns a video exported from your editor (any size, any format) into a small
// looping clip for the site, next to the Markdown that shows it:
//
//   npm run video -- ~/Exports/build-mode.mov ../content/blog/my-post
//   npm run video -- master.mov ../content/work/thrall-guard/cover.mp4 --size card
//
// It picks the settings itself. For each format it searches for the smallest
// file that still looks like your export, measured with VMAF (Netflix's
// "how close does this look to the original" score, 0 to 100). Only if that
// file is over the size's budget does it give up a little more quality, down
// to a floor, and it tells you when it did.
//
// Makes three files, all committed with the content:
//   name.mp4      H.264: plays in every browser
//   name.av1.mp4  AV1: much smaller, used by browsers that can play it
//                 (skipped when it wouldn't be smaller)
//   name.jpg      the first frame, shown until the clip starts
//
// Sound is always removed: the site's clips are muted loops. Keep the master
// out of the repository; only these outputs go in.
//
// Options:
//   --size card|inline|hero  how wide it's shown (default inline):
//                              card   960 px wide, for cards and covers   (budget: 1 MB)
//                              inline 1280 px, inside a post or doc       (budget: 3 MB)
//                              hero   1600 px, full width                 (budget: 5 MB)
//                            (the budget is for the AV1 file most browsers get;
//                            the H.264 fallback may use half as much again)
//   --quality N    the VMAF score to keep (default 93: hard to tell from the export)
//   --crf N        skip the search and use this H.264 quality (lower is sharper and bigger)
//   --fps N        frames per second (default: the export's own, at most 30)
//   --start S      skip the first S seconds of the master
//   --length S     keep S seconds (4 to 10 loop best)
//
// Needs ffmpeg (on a Mac: brew install ffmpeg). The build never runs this, so
// Netlify doesn't need it.
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, renameSync, rmSync, statSync } from 'node:fs';
import { cpus, tmpdir } from 'node:os';
import { basename, dirname, extname, join, resolve } from 'node:path';

const SIZES = {
  card: { width: 960, aimMB: 1 },
  inline: { width: 1280, aimMB: 3 },
  hero: { width: 1600, aimMB: 5 },
};
/** The H.264 fallback may be this much bigger than the budget. */
const H264_ALLOWANCE = 1.5;
/** Quality range each encoder searches: [sharpest, softest allowed]. */
const CODECS = {
  h264: { range: [18, 34], args: (crf) => ['-c:v', 'libx264', '-preset', 'slow', '-crf', String(crf), '-profile:v', 'high', '-tag:v', 'avc1'] },
  av1: { range: [22, 50], args: (crf) => ['-c:v', 'libsvtav1', '-preset', '5', '-crf', String(crf)] },
};

function fail(message) {
  console.error(`video: ${message}`);
  process.exit(1);
}

// --- Arguments ----------------------------------------------------------------
const positional = [];
const options = {};
const argv = process.argv.slice(2);
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a.startsWith('--')) options[a.slice(2)] = argv[++i];
  else positional.push(a);
}
const [master, where] = positional;
if (!master || !where) {
  fail('usage: npm run video -- <exported video> <content folder or name.mp4> [--size card|inline|hero] [--quality N] [--crf N] [--fps N] [--start S] [--length S]');
}
if (!existsSync(master)) fail(`no such file: ${master}`);
const sizeName = options.size ?? 'inline';
const size = SIZES[sizeName];
if (!size) fail(`--size is card, inline or hero, not "${options.size}"`);
const targetQuality = Number(options.quality ?? 93);

const slug = basename(master, extname(master))
  .toLowerCase()
  .replace(/[^a-z0-9]+/g, '-')
  .replace(/^-|-$/g, '');
const mp4 = resolve(/\.mp4$/i.test(where) ? where : join(where, `${slug}.mp4`));
if (mp4 === resolve(master)) fail('the output would overwrite the master; pick another name');
const av1 = mp4.replace(/\.mp4$/i, '.av1.mp4');
const poster = mp4.replace(/\.mp4$/i, '.jpg');
mkdirSync(dirname(mp4), { recursive: true });

// --- ffmpeg ---------------------------------------------------------------------
const probe = spawnSync('ffmpeg', ['-hide_banner', '-encoders'], { encoding: 'utf8' });
if (probe.error) fail('ffmpeg is not installed. On a Mac: brew install ffmpeg');
const hasAv1 = probe.stdout.includes('libsvtav1');
const filters = spawnSync('ffmpeg', ['-hide_banner', '-filters'], { encoding: 'utf8' }).stdout;
const hasVmaf = filters.includes('libvmaf');

function run(args) {
  const r = spawnSync('ffmpeg', ['-hide_banner', '-y', ...args], {
    encoding: 'utf8',
    maxBuffer: 64 * 2 ** 20,
    stdio: ['ignore', 'ignore', 'pipe'],
    env: { ...process.env, SVT_LOG: '1' },
  });
  if (r.status !== 0) fail(`ffmpeg failed:\n${(r.stderr ?? '').split('\n').slice(-8).join('\n')}`);
  return r.stderr ?? '';
}

// The export's own frame rate (never raised: that only repeats frames).
function sourceFps() {
  const r = spawnSync('ffprobe', ['-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=avg_frame_rate', '-of', 'csv=p=0', master], { encoding: 'utf8' });
  const [n, d] = String(r.stdout).trim().split('/').map(Number);
  const value = d ? n / d : n;
  return Number.isFinite(value) && value > 0 ? value : 30;
}
const fps = options.fps ? Number(options.fps) : Math.min(30, Math.round(sourceFps()));

const input = [
  ...(options.start ? ['-ss', String(options.start)] : []),
  '-i', master,
  ...(options.length ? ['-t', String(options.length)] : []),
];
// Never wider than asked (or than the master), even height, square pixels, 8-bit 4:2:0 (what Safari needs).
const filter = `scale='min(${size.width},iw)':-2:flags=lanczos,setsar=1,fps=${fps},format=yuv420p`;
const common = ['-an', '-map_metadata', '-1', '-g', String(fps * 2), '-movflags', '+faststart'];

const work = mkdtempSync(join(tmpdir(), 'site-video-'));
process.on('exit', () => rmSync(work, { recursive: true, force: true }));

// The reference every try is scored against: the export at the clip's size and
// frame rate, without loss.
const reference = join(work, 'reference.mkv');
process.stdout.write('video: preparing… ');
run([...input, '-vf', filter, '-an', '-c:v', 'libx264', '-preset', 'ultrafast', '-qp', '0', reference]);
console.log(`${fps} fps`);

// Frames are paired by number, not time: the two files count time in slightly
// different units, and pairing by time drifts by a frame.
function vmaf(file) {
  const threads = Math.max(2, Math.min(8, cpus().length));
  const log = run(['-i', file, '-i', reference, '-lavfi', `[0:v]settb=1/${fps},setpts=N[a];[1:v]settb=1/${fps},setpts=N[b];[a][b]libvmaf=n_threads=${threads}:n_subsample=2`, '-f', 'null', '-']);
  const m = /VMAF score:\s*([\d.]+)/.exec(log);
  return m ? Number(m[1]) : 0;
}

const MB = 2 ** 20;
const sizeOf = (file) => statSync(file).size;

/**
 * Encodes with [codec] at the softest quality that still scores [targetQuality],
 * then, if that's over [budget] bytes, softer until it fits or the floor is reached.
 * Each quality setting is tried once; the search halves the range each time.
 */
function encode(codec, out, budget, label) {
  const { range, args } = CODECS[codec];
  const tries = new Map();
  const attempt = (crf) => {
    if (!tries.has(crf)) {
      const file = join(work, `${codec}-${crf}.mp4`);
      run([...input, '-vf', filter, ...common, ...args(crf), file]);
      tries.set(crf, { crf, file, bytes: sizeOf(file), score: hasVmaf ? vmaf(file) : 100 });
      const t = tries.get(crf);
      console.log(`         ${label} quality ${String(crf).padStart(2)}: ${(t.bytes / MB).toFixed(2)} MB, looks ${t.score.toFixed(1)}/100`);
    }
    return tries.get(crf);
  };

  let best;
  if (options.crf && codec === 'h264') {
    best = attempt(Number(options.crf));
  } else {
    // 1. The softest setting that still looks like the export.
    let [lo, hi] = range;
    while (lo <= hi) {
      const mid = Math.floor((lo + hi) / 2);
      const t = attempt(mid);
      if (t.score >= targetQuality) {
        best = t; // passes: try softer
        lo = mid + 1;
      } else hi = mid - 1;
    }
    best ??= attempt(range[0]); // nothing passed: the sharpest allowed
    // 2. Over budget? Softer, as little as needed (down to the floor).
    if (best.bytes > budget) {
      let [lo2, hi2] = [best.crf + 1, range[1]];
      let fit;
      while (lo2 <= hi2) {
        const mid = Math.floor((lo2 + hi2) / 2);
        const t = attempt(mid);
        if (t.bytes <= budget) {
          fit = t;
          hi2 = mid - 1;
        } else lo2 = mid + 1;
      }
      best = fit ?? attempt(range[1]);
    }
  }
  renameSync(best.file, out);
  return best;
}

console.log(`video: searching for the smallest ${hasVmaf ? `file that scores ${targetQuality}+` : 'file in budget'} (budget ${size.aimMB} MB)…`);
const picked = {};
picked.h264 = encode('h264', mp4, size.aimMB * H264_ALLOWANCE * MB, 'H.264');
if (hasAv1) {
  picked.av1 = encode('av1', av1, size.aimMB * MB, 'AV1  ');
  // Not worth a second file unless it saves at least a tenth.
  if (sizeOf(av1) > sizeOf(mp4) * 0.9) {
    rmSync(av1);
    delete picked.av1;
    console.log('video: the AV1 version was no smaller, so it was left out');
  }
} else {
  if (existsSync(av1)) rmSync(av1);
  console.log('video: this ffmpeg has no AV1 encoder (libsvtav1); made only the H.264 version');
}
run(['-i', mp4, '-frames:v', '1', '-q:v', '3', poster]);

// --- Report -------------------------------------------------------------------------
console.log('');
for (const [file, t] of [[mp4, picked.h264], [av1, picked.av1], [poster]]) {
  if (!existsSync(file)) continue;
  const quality = t ? `quality ${t.crf}, looks ${t.score.toFixed(1)}/100` : '';
  console.log(`  ${basename(file).padEnd(32)} ${(sizeOf(file) / MB).toFixed(2).padStart(6)} MB   ${quality}`);
}
console.log('');
const main = picked.av1 ?? picked.h264;
if (hasVmaf && main.score < targetQuality) {
  console.log(
    `video: to stay within ${size.aimMB} MB it looks ${main.score.toFixed(1)}/100 rather than ${targetQuality}. ` +
      'A shorter --length or a smaller --size would keep it sharper.',
  );
}
if (fps < 24) console.log(`video: the export is ${fps} fps, so motion will look choppy. Export at 24 or 30 fps if the footage allows.`);
console.log(`video: done. In Markdown, next to it:  ::video ./${basename(mp4)} Optional caption`);
