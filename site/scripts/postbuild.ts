// Runs after `astro build`:
//
// 1. Writes dist/_redirects for Netlify: Netlify's own address → elmarath.com,
//    every address of the previous (Docusaurus) site → today's page (301), and
//    the old `?tag=` blog links. Anything else unknown lands on the 404 page,
//    which still matches old addresses loosely (src/scripts/legacy-core.ts).
// 2. Checks every internal link on every page goes somewhere real, and fails
//    the build if one doesn't.
import { existsSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { join, relative } from 'node:path';
import { site } from '../src/config.ts';
import { content, repoRoot } from '../src/content/repository.ts';
import { legacyRoute } from '../src/scripts/legacy-core.ts';

const dist = join(process.cwd(), 'dist');
const repo = content();
const data = repo.legacyData;
const routes = new Set(data.routes);

// --- 1. Redirects ------------------------------------------------------------
const lines: string[] = [
  '# Made by scripts/postbuild.ts. Edit `movedPages` in src/config.ts, or the content, instead.',
  '',
  "# Netlify's own address sends visitors and search engines to the same page on the real one.",
  `http://${site.netlifyHost}/*  ${site.url}/:splat  301!`,
  `https://${site.netlifyHost}/*  ${site.url}/:splat  301!`,
  '',
  '# Blog tag links of the previous sites.',
  '/blog  tag=:tag  /blog/tag/:tag  301',
  '/blog/tags/:tag  /blog/tag/:tag  301',
  '',
  '# Addresses of the previous (Docusaurus) site.',
];

/** Every address the old Docusaurus site had for the docs: its folder and file names, as they were. */
const oldAddresses = new Set<string>();
const fixture = join(repoRoot, 'test', 'fixtures', 'old_site_urls.txt');
if (existsSync(fixture)) {
  for (const line of readFileSync(fixture, 'utf8').split('\n')) {
    const t = line.trim();
    if (t && !t.startsWith('#')) oldAddresses.add(t);
  }
}
for (const from of Object.keys(site.movedPages)) oldAddresses.add(encodeURI(from));
for (const doc of repo.docPages) {
  const parts = doc.assetPath.replace(/^content\//, '').replace(/\.mdx?$/, '').split('/');
  const isIndex = /^(index|readme)$/i.test(parts.at(-1)!);
  const path = `/${(isIndex ? parts.slice(0, -1) : parts).join('/')}`;
  oldAddresses.add(encodeURI(path));
}
for (const c of repo.categories) {
  oldAddresses.add(`/docs/category/${c.label.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')}`);
  for (const alias of c.aliases) {
    // Pages under a folder that used to be spelled differently.
    const folder = c.assetDir.split('/').at(-1)!;
    for (const doc of repo.docPages.filter((d) => d.assetPath.startsWith(`${c.assetDir}/`))) {
      const path = `/${doc.assetPath.replace(/^content\//, '').replace(/\.mdx?$/, '').replace(`/${folder}/`, `/${alias}/`)}`;
      oldAddresses.add(encodeURI(path));
    }
  }
}
const redirects: [string, string][] = [];
for (const from of [...oldAddresses].sort()) {
  if (routes.has(from) || from.includes('?')) continue;
  if (/^\/blog\/tags?\//i.test(from)) continue; // covered by the pattern above
  const to = legacyRoute(from, data);
  if (to && to !== from) redirects.push([from, to]);
}
lines.push(...redirects.map(([from, to]) => `${from}  ${to}  301`));

// A page that is also a folder (/docs/plugin and /docs/plugin/page): serve the
// page for the folder's address too, whatever the host does with folders.
const rewrites: string[] = [];
const walkHtml = (dir: string, out: string[] = []) => {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walkHtml(p, out);
    else if (name.endsWith('.html')) out.push(p);
  }
  return out;
};
const pages = walkHtml(dist);
for (const file of pages) {
  const route = `/${relative(dist, file).split('\\').join('/').replace(/\.html$/, '')}`;
  if (existsSync(join(dist, route.slice(1))) && statSync(join(dist, route.slice(1))).isDirectory()) rewrites.push(`${route}  ${route}.html  200`);
}
if (rewrites.length) lines.push('', '# Pages that share their name with a folder.', ...rewrites.sort());
writeFileSync(join(dist, '_redirects'), `${lines.join('\n')}\n`);

// --- 2. Links -----------------------------------------------------------------
const exists = (path: string) => {
  const clean = decodeURI(path.split('#')[0].split('?')[0]).replace(/\/$/, '') || '/';
  if (clean === '/') return existsSync(join(dist, 'index.html'));
  return (
    existsSync(join(dist, `${clean.slice(1)}.html`)) ||
    existsSync(join(dist, clean.slice(1), 'index.html')) ||
    (existsSync(join(dist, clean.slice(1))) && statSync(join(dist, clean.slice(1))).isFile())
  );
};
const broken = new Map<string, Set<string>>();
for (const file of pages) {
  const html = readFileSync(file, 'utf8');
  for (const m of html.matchAll(/\s(?:href|src)="(\/[^"]*)"/g)) {
    const href = m[1].replace(/&amp;/g, '&');
    if (href.startsWith('//') || href.startsWith('/_astro/') || exists(href)) continue;
    const page = `/${relative(dist, file).replace(/\.html$/, '')}`;
    if (!broken.has(href)) broken.set(href, new Set());
    broken.get(href)!.add(page);
  }
}
console.log(`postbuild: ${redirects.length} redirects, ${rewrites.length} folder rewrites, ${pages.length} pages checked`);
if (broken.size) {
  for (const [href, from] of broken) console.error(`  broken link ${href}  (on ${[...from].slice(0, 3).join(', ')})`);
  console.error(`postbuild: ${broken.size} broken link(s)`);
  process.exitCode = 1;
}
