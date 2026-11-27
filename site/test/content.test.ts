// Content tests: the same checks as the Flutter site's test/content_test.dart,
// so URLs, anchors and old links behave exactly as before. Run: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { FrontMatter, slugify } from '../src/content/text.ts';
import { preprocess, parseYoutube } from '../src/content/markdown-source.ts';
import { content, resolveAsset } from '../src/content/repository.ts';
import { legacyRoute } from '../src/scripts/legacy-core.ts';
import { searchEntries } from '../src/scripts/search-core.ts';

const repo = content();
const routes = new Set(repo.routes);
const land = (address: string) => {
  const url = new URL(address, 'https://elmarath.com');
  return legacyRoute(url.pathname, repo.legacyData) ?? decodeURI(url.pathname);
};

test('slugify handles Docusaurus-style names', () => {
  assert.equal(slugify('Easy-Trace-Trail-System'), 'easy-trace-trail-system');
  assert.equal(slugify('AbilitySets.md'), 'ability-sets');
  assert.equal(slugify('Decide%20Montages'), 'decide-montages');
  assert.equal(slugify('02-setup'), 'setup');
  assert.equal(slugify("Hermod's Ride"), 'hermods-ride');
});

test('front matter splits YAML from the body and keeps colons in list items', () => {
  const doc = FrontMatter.parse('---\ntitle: Hello\ntags: [a, b]\n---\n\nBody');
  assert.equal(doc.string('title'), 'Hello');
  assert.deepEqual(doc.list('tags'), ['a', 'b']);
  assert.equal(doc.body.trim(), 'Body');
  assert.equal(FrontMatter.parse('# Title').body, '# Title');
  assert.deepEqual(FrontMatter.parse('---\nhighlights:\n  - No limit: any depth\n  - Plain\n---\n').list('highlights'), ['No limit: any depth', 'Plain']);
});

test('markdown extensions: callouts, videos, alerts, fences', () => {
  const out = preprocess(`Intro

:::tip **Before you start**
    Indented content
:::

::youtube https://www.youtube.com/watch?v=abc123&t=90

\`\`\`cpp
:::note
\`\`\`

> [!WARNING]
> Careful

<iframe src="https://www.youtube.com/embed/xyz?start=12"></iframe>
::plugin-links`);
  assert.match(out, /<aside class="callout callout-tip" data-callout="tip" data-title="Before you start">\n\nIndented content\n\n<\/aside>/);
  assert.match(out, /<div data-youtube="abc123" data-start="90"><\/div>/);
  assert.match(out, /```cpp\n:::note\n```/, 'nothing inside a code fence changes');
  assert.match(out, /callout-warning[^>]*>\n\nCareful/);
  assert.match(out, /data-youtube="xyz" data-start="12"/);
  assert.match(out, /data-directive="plugin-links"/);
  assert.deepEqual(parseYoutube('https://youtu.be/sX3nIh14bYM'), { videoId: 'sX3nIh14bYM', start: undefined });
});

test('content loads: docs, posts and pages', () => {
  assert.ok(repo.docPages.length > 20);
  assert.ok(repo.plugins.length >= 8);
  assert.ok(repo.posts.length >= 2);
  assert.ok(repo.pages.has('about') && repo.pages.has('privacy-policy'));
  for (const p of repo.posts) assert.ok(p.slug && p.title, p.assetPath);
  for (const d of repo.docPages) assert.ok(d.title && d.route.startsWith('/docs/'), d.assetPath);
});

test('resolves Docusaurus links and relative files', () => {
  assert.equal(repo.internalRoute('/docs/Easy-Ability-Set-System/AbilitySets', 'content/docs/x.md'), '/docs/easy-ability-set-system/ability-sets');
  assert.equal(repo.internalRoute('./Setup.md#sections', 'content/docs/Easy-Trace-Trail-System/FinalNotes.md'), '/docs/easy-trace-trail-system/setup#sections');
  assert.equal(repo.internalRoute('https://example.com', 'content/docs/x.md'), null);
  assert.equal(resolveAsset('content/docs/A/B/page.md', '../img/x.png'), 'content/docs/A/img/x.png');
});

test('every address from the old site lands on a page', () => {
  const old = readFileSync(new URL('./fixtures/old_site_urls.txt', import.meta.url), 'utf8')
    .split('\n')
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith('#'));
  const broken = old.filter((a) => !routes.has(land(a))).map((a) => `${a} → ${land(a)}`);
  assert.deepEqual(broken, []);
  // Spot checks, including the lowercase link printed in the CV and letter-case mix-ups.
  assert.equal(land('/docs/PrivacyPolicy'), '/privacy-policy');
  assert.equal(land('/docs/easy-ability-set-system/easyabilitysetsystemstartup'), '/docs/easy-ability-set-system/easy-ability-set-system-startup');
  assert.equal(land('/docs/Nested-Invnetory-Architecture/Quick-Start-To-NIA'), '/docs/nested-inventory-architecture/quick-start-to-nia');
  assert.equal(land('/docs/category/decide-montages'), '/docs/modular-action-system/decide-montages');
  assert.equal(land('/blog/Welcome%20to%20Elmarath%20Studio'), '/blog/welcome-to-elmarath-studio');
  assert.equal(land('/DOCS/staged-interaction-system/SETUP'), '/docs/staged-interaction-system/setup');
  assert.equal(land('/blog/tags/hermods-ride'), '/blog/tag/hermods-ride');
  // Current pages are left alone.
  assert.equal(legacyRoute('/docs/intro', repo.legacyData), null);
});

test('internal doc links point at real pages', () => {
  const link = /(?<!!)\[[^\]]*\]\(([^)\s]+)\)/g;
  const missing: string[] = [];
  for (const { assetPath, body } of [...repo.docPages, ...repo.pages.values(), ...repo.posts]) {
    for (const m of body.matchAll(link)) {
      const route = repo.internalRoute(m[1], assetPath);
      if (route == null || route.startsWith('#') || /\.(pdf|zip|png|jpe?g)$/i.test(route)) continue;
      const path = route.split('#')[0];
      if (!routes.has(path) && !routes.has(land(path))) missing.push(`${assetPath} → ${route}`);
    }
  }
  assert.deepEqual(missing, []);
});

test('search ranks title over headings over text, and every word must match', () => {
  const [a, b, c] = searchEntries([
    { kind: 'doc', title: 'Inventory setup', context: '', route: '/a', headings: '', text: 'x' },
    { kind: 'doc', title: 'Other', context: '', route: '/b', headings: 'inventory', text: 'x' },
    { kind: 'doc', title: 'Other', context: '', route: '/c', headings: '', text: 'the inventory' },
  ]);
  assert.ok(a.score(['inventory']) > b.score(['inventory']));
  assert.ok(b.score(['inventory']) > c.score(['inventory']));
  assert.equal(c.score(['inventory', 'missing']), 0);
});

test('the website editor covers every docs folder and edits bodies as plain Markdown', async () => {
  const { parse } = await import('yaml');
  const { cmsConfig } = await import('../src/content/cms.ts');
  const config = parse(cmsConfig(repo.categories));
  const folders = new Set(config.collections.map((c: { folder: string }) => c.folder));
  for (const c of repo.categories) assert.ok(folders.has(c.assetDir), `no editor collection for ${c.assetDir}`);
  for (const c of config.collections) {
    assert.equal(c.extension, 'md');
    const body = c.fields.find((f: { name: string }) => f.name === 'body');
    assert.deepEqual(body.modes, ['raw'], `${c.name} must edit raw Markdown, or callouts and ::youtube get rewritten`);
  }
  assert.equal(new Set(config.collections.map((c: { name: string }) => c.name)).size, config.collections.length);
});

test('every doc page\'s Edit button opens an entry the editor has', async () => {
  const { parse } = await import('yaml');
  const { cmsConfig, editorUrl } = await import('../src/content/cms.ts');
  const config = parse(cmsConfig(repo.categories));
  const byName = new Map(config.collections.map((c: { name: string; folder: string }) => [c.name, c.folder]));
  for (const doc of repo.docPages) {
    const m = editorUrl(doc).match(/^\/admin#\/collections\/([^/]+)\/entries\/([^/]+)$/);
    assert.ok(m, editorUrl(doc));
    assert.equal(`${byName.get(m[1])}/${decodeURIComponent(m[2])}.md`, doc.assetPath);
  }
});
