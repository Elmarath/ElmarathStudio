// The one script every page runs, loaded once per visit (pages after that are
// swapped in by the client router). Everything here waits for a click or a key:
// nothing runs per frame, nothing runs while scrolling. Elements are looked up
// when they're needed, since each page swap brings new ones.
import { searchEntries, highlight, type IndexedEntry } from './search-core.ts';
import { onPage } from './lifecycle.ts';
import './loop-video.ts';
import './feedback.ts';

const $ = <T extends Element>(sel: string, root: ParentNode = document) => root.querySelector<T>(sel);
const isMac = /Mac|iPhone|iPad/.test(navigator.platform);

onPage(() => {
  for (const k of document.querySelectorAll('[data-shortcut]')) k.textContent = isMac ? '⌘ K' : 'Ctrl K';
});

// --- Theme ------------------------------------------------------------------
// (Applying the saved theme before each page shows is in the <head> of src/layouts/Base.astro.)
document.addEventListener('click', (e) => {
  const item = (e.target as Element).closest<HTMLElement>('[data-set-theme]');
  if (!item) return;
  const id = item.dataset.setTheme!;
  document.documentElement.dataset.theme = id;
  try {
    localStorage.setItem('theme', id);
  } catch {}
  const colors = (window as unknown as { __themeColors?: Record<string, string> }).__themeColors;
  if (colors?.[id]) $<HTMLMetaElement>('meta[name="theme-color"]')?.setAttribute('content', colors[id]);
  $<HTMLElement>('#theme-menu')?.hidePopover?.();
});

// --- Search -----------------------------------------------------------------
const searchDialog = () => $<HTMLDialogElement>('#search');
let index: Promise<IndexedEntry[]> | undefined;
const loadIndex = () =>
  (index ??= fetch('/search.json')
    .then((r) => r.json())
    .then(searchEntries)
    .catch(() => {
      index = undefined;
      return [];
    }));

function openSearch() {
  const dialog = searchDialog();
  if (!dialog || dialog.open) return;
  dialog.showModal();
  $<HTMLInputElement>('input', dialog)!.select();
  void loadIndex();
}
document.addEventListener('click', (e) => {
  const target = e.target as Element;
  if (target.closest('[data-search]')) openSearch();
  else if (target === searchDialog()) searchDialog()!.close(); // a click on the backdrop
  else if (target.closest('#search-results a')) searchDialog()?.close();
});
// Warm the index as soon as someone reaches for the search box.
document.addEventListener('pointerover', (e) => {
  if ((e.target as Element).closest?.('[data-search]')) void loadIndex();
});
document.addEventListener('focusin', (e) => {
  if ((e.target as Element).closest?.('[data-search]')) void loadIndex();
});
document.addEventListener('keydown', (e) => {
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
    e.preventDefault();
    const dialog = searchDialog();
    if (dialog?.open) dialog.close();
    else openSearch();
  }
});

let selected = 0;
async function runSearch(input: HTMLInputElement) {
  const results = $<HTMLElement>('#search-results');
  if (!results) return;
  const query = input.value.trim();
  if (!query) {
    results.innerHTML = '<p class="hint">Type to search docs, blog posts and pages.</p>';
    return;
  }
  const entries = await loadIndex();
  if (input.value.trim() !== query) return; // typed on meanwhile
  const terms = query.toLowerCase().split(/\s+/).filter(Boolean);
  const hits = entries
    .map((e) => [e, e.score(terms)] as const)
    .filter(([, s]) => s > 0)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 20);
  if (hits.length === 0) {
    results.innerHTML = '';
    const p = document.createElement('p');
    p.className = 'hint';
    p.textContent = `No results for “${query}”`;
    results.append(p);
    return;
  }
  const icons: Record<string, string> = {};
  for (const t of document.querySelectorAll<HTMLTemplateElement>('template[data-search-icon]')) icons[t.dataset.searchIcon!] = t.innerHTML;
  selected = 0;
  results.innerHTML = hits
    .map(
      ([e], i) =>
        `<a href="${e.route}" role="option" aria-selected="${i === 0}">${icons[e.kind] ?? ''}` +
        `<span class="overline">${highlight(e.context, [])}</span>` +
        `<span class="title">${highlight(e.title, terms)}</span>` +
        `<span class="snippet">${highlight(e.snippet(terms[0]), terms)}</span></a>`,
    )
    .join('');
}
document.addEventListener('input', (e) => {
  const input = e.target as HTMLInputElement;
  if (input.closest?.('#search')) void runSearch(input);
});
document.addEventListener('keydown', (e) => {
  if (!(e.target as Element).closest?.('#search input')) return;
  const items = [...document.querySelectorAll<HTMLAnchorElement>('#search-results a')];
  if (items.length === 0) return;
  if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
    e.preventDefault();
    items[selected]?.setAttribute('aria-selected', 'false');
    selected = (selected + (e.key === 'ArrowDown' ? 1 : -1) + items.length) % items.length;
    items[selected].setAttribute('aria-selected', 'true');
    items[selected].scrollIntoView({ block: 'nearest' });
  } else if (e.key === 'Enter') {
    e.preventDefault();
    items[selected]?.click();
  }
});

// --- CV window ----------------------------------------------------------------
document.addEventListener('click', (e) => {
  const cv = $<HTMLDialogElement>('#cv');
  if (e.target === cv) {
    cv!.close(); // a click on the backdrop
    return;
  }
  const link = (e.target as Element).closest<HTMLAnchorElement>('a[href="/cv"]');
  if (!link || !cv || e.metaKey || e.ctrlKey || e.shiftKey || location.pathname === '/cv') return;
  e.preventDefault();
  const frame = $<HTMLIFrameElement>('iframe', cv)!;
  if (!frame.src) frame.src = frame.dataset.src!;
  cv.showModal();
});

// --- Images: click to see them full size ------------------------------------
document.addEventListener('click', (e) => {
  const link = (e.target as Element).closest<HTMLAnchorElement>('a[data-zoom]');
  if (!link || e.metaKey || e.ctrlKey) return;
  e.preventDefault();
  let viewer = $<HTMLDialogElement>('dialog.image-viewer');
  if (!viewer) {
    viewer = document.createElement('dialog');
    viewer.className = 'image-viewer';
    viewer.innerHTML = '<img alt="">';
    viewer.addEventListener('click', () => viewer!.close());
    document.body.append(viewer);
  }
  const img = viewer.querySelector('img')!;
  img.src = link.href;
  img.alt = link.querySelector('img')?.alt ?? '';
  viewer.showModal();
});

// --- Code blocks: copy -------------------------------------------------------
document.addEventListener('click', async (e) => {
  const button = (e.target as Element).closest<HTMLButtonElement>('[data-copy]');
  if (!button) return;
  const code = button.closest('figure')?.querySelector('pre')?.innerText ?? '';
  try {
    await navigator.clipboard.writeText(code.replace(/\n$/, ''));
    const label = button.querySelector('span');
    if (label) {
      label.textContent = 'Copied';
      setTimeout(() => (label.textContent = 'Copy'), 1500);
    }
  } catch {}
});

// --- YouTube: the player loads only when played --------------------------------
document.addEventListener('click', (e) => {
  const poster = (e.target as Element).closest<HTMLAnchorElement>('.youtube-poster');
  if (!poster || e.metaKey || e.ctrlKey) return;
  const box = poster.parentElement as HTMLElement;
  e.preventDefault();
  const start = box.dataset.start ? `&start=${box.dataset.start}` : '';
  const frame = document.createElement('iframe');
  frame.src = `https://www.youtube-nocookie.com/embed/${box.dataset.video}?autoplay=1&rel=0${start}`;
  frame.title = poster.getAttribute('aria-label') ?? 'YouTube video';
  frame.allow = 'autoplay; encrypted-media; picture-in-picture; fullscreen';
  frame.allowFullscreen = true;
  box.replaceChildren(frame);
});
