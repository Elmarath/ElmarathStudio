// The home page plugin carousel: moves on every 7 seconds while it's on
// screen and not paused; the list picks a plugin; a swipe (touch screens) is
// native scrolling, and the list follows wherever it lands.
// Everything stops with [signal] (the page being swapped out).
import { observe } from './lifecycle.ts';

const INTERVAL = 7000;

export function startCarousels(signal: AbortSignal) {
  for (const root of document.querySelectorAll<HTMLElement>('[data-carousel]')) start(root, signal);
}

function start(root: HTMLElement, signal: AbortSignal) {
  const track = root.querySelector<HTMLElement>('.slides')!;
  const slides = [...track.querySelectorAll<HTMLElement>('.slide')];
  const tabs = [...root.querySelectorAll<HTMLButtonElement>('.tab')];
  const list = root.querySelector<HTMLElement>('.tabs')!;
  const pause = root.querySelector<HTMLButtonElement>('[data-pause]')!;
  if (slides.length < 2) {
    pause.hidden = true;
    return;
  }
  let index = 0;
  let paused = false;
  let onScreen = false;
  let timer: ReturnType<typeof setTimeout> | undefined;
  /** The slide our own scroll is heading to; until it gets there, no scroll position counts as a swipe. */
  let target: number | undefined;
  const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;

  const select = (i: number, { scroll = true } = {}) => {
    index = (i + slides.length) % slides.length;
    tabs.forEach((t, n) => t.setAttribute('aria-selected', String(n === index)));
    if (scroll) {
      target = index;
      track.scrollTo({ left: index * track.clientWidth, behavior: reduceMotion ? 'auto' : 'smooth' });
    }
    reveal();
    schedule();
  };

  /** Scrolls the list (only the list, never the page) so the plugin on show is in view. */
  const reveal = () => {
    const tab = tabs[index];
    const vertical = list.scrollHeight > list.clientHeight + 1 && getComputedStyle(list).flexDirection === 'column';
    if (vertical) {
      const top = tab.offsetTop - list.offsetTop;
      if (top < list.scrollTop || top + tab.offsetHeight > list.scrollTop + list.clientHeight) {
        list.scrollTo({ top: top - (list.clientHeight - tab.offsetHeight) / 2, behavior: 'smooth' });
      }
    } else {
      const left = tab.offsetLeft - list.offsetLeft;
      if (left < list.scrollLeft || left + tab.offsetWidth > list.scrollLeft + list.clientWidth) {
        list.scrollTo({ left: left - (list.clientWidth - tab.offsetWidth) / 2, behavior: 'smooth' });
      }
    }
  };

  // The timer only runs while the carousel is visible and the tab is in front.
  const schedule = () => {
    clearTimeout(timer);
    timer = undefined;
    tabs.forEach((t) => t.classList.remove('running'));
    if (paused || !onScreen || document.hidden) return;
    timer = setTimeout(() => select(index + 1), INTERVAL);
    // The bar under the plugin on show fills over the same time.
    void tabs[index].offsetWidth;
    tabs[index].classList.add('running');
  };

  signal.addEventListener('abort', () => clearTimeout(timer));
  tabs.forEach((tab, i) => tab.addEventListener('click', () => select(i), { signal }));
  pause.addEventListener('click', () => {
    paused = !paused;
    root.toggleAttribute('data-paused', paused);
    pause.setAttribute('aria-label', paused ? 'Play' : 'Pause');
    pause.title = paused ? 'Play' : 'Pause';
    schedule();
  }, { signal });

  // A swipe: when the row settles, the list follows and the timer starts over.
  // Only a swipe may change the slide this way. Our own scrolls (a click on the
  // list, the timer) can settle part-way when one interrupts another, and a
  // click-and-drag on wide screens can nudge the hidden row through text
  // selection; both are put back on the slide that was picked.
  let settle: ReturnType<typeof setTimeout> | undefined;
  const swipeable = () => getComputedStyle(track).overflowX !== 'hidden';
  const settled = () => {
    const i = Math.round(track.scrollLeft / track.clientWidth);
    if (target !== undefined) {
      if (i === target) target = undefined;
      else track.scrollTo({ left: target * track.clientWidth, behavior: reduceMotion ? 'auto' : 'smooth' });
      return;
    }
    if (i === index) return;
    if (swipeable()) select(i, { scroll: false });
    else track.scrollTo({ left: index * track.clientWidth });
  };
  if ('onscrollend' in window) track.addEventListener('scrollend', settled, { signal });
  else
    track.addEventListener('scroll', () => {
      clearTimeout(settle);
      settle = setTimeout(settled, 120);
    }, { passive: true, signal });
  // A finger or a trackpad on the row: from here on the person is steering.
  const takeOver = () => {
    target = undefined;
    clearTimeout(timer);
    tabs.forEach((t) => t.classList.remove('running'));
  };
  track.addEventListener('touchstart', takeOver, { passive: true, signal });
  track.addEventListener('wheel', (e) => { if (Math.abs(e.deltaX) > Math.abs(e.deltaY)) takeOver(); }, { passive: true, signal });
  track.addEventListener('pointerdown', () => {
    clearTimeout(timer);
    tabs.forEach((t) => t.classList.remove('running'));
  }, { passive: true, signal });

  // Keep the slide in place when the window is resized.
  const resize = new ResizeObserver(() => {
    target = undefined;
    track.scrollTo({ left: index * track.clientWidth });
  });
  resize.observe(track);
  signal.addEventListener('abort', () => resize.disconnect());
  observe(signal, root, (entries) => {
    onScreen = entries.at(-1)!.isIntersecting;
    schedule();
  });
  document.addEventListener('visibilitychange', schedule, { signal });
}
