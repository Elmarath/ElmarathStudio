// The home page plugin carousel: moves on every 7 seconds while it's on
// screen and not paused; the list picks a plugin; a swipe (touch screens) is
// native scrolling, and the list follows wherever it lands.
const INTERVAL = 7000;

export function startCarousels() {
  for (const root of document.querySelectorAll<HTMLElement>('[data-carousel]')) start(root);
}

function start(root: HTMLElement) {
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
  const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;

  const select = (i: number, { scroll = true } = {}) => {
    index = (i + slides.length) % slides.length;
    tabs.forEach((t, n) => t.setAttribute('aria-selected', String(n === index)));
    if (scroll) track.scrollTo({ left: index * track.clientWidth, behavior: reduceMotion ? 'auto' : 'smooth' });
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
    if (paused || !onScreen || document.hidden) return;
    timer = setTimeout(() => select(index + 1), INTERVAL);
  };

  tabs.forEach((tab, i) => tab.addEventListener('click', () => select(i)));
  pause.addEventListener('click', () => {
    paused = !paused;
    root.toggleAttribute('data-paused', paused);
    pause.setAttribute('aria-label', paused ? 'Play' : 'Pause');
    pause.title = paused ? 'Play' : 'Pause';
    schedule();
  });

  // A swipe: when the row settles, the list follows and the timer starts over.
  let settle: ReturnType<typeof setTimeout> | undefined;
  const settled = () => {
    const i = Math.round(track.scrollLeft / track.clientWidth);
    if (i !== index) select(i, { scroll: false });
  };
  if ('onscrollend' in window) track.addEventListener('scrollend', settled);
  else
    track.addEventListener('scroll', () => {
      clearTimeout(settle);
      settle = setTimeout(settled, 120);
    }, { passive: true });
  track.addEventListener('pointerdown', () => clearTimeout(timer), { passive: true });

  // Keep the slide in place when the window is resized.
  new ResizeObserver(() => track.scrollTo({ left: index * track.clientWidth })).observe(track);
  new IntersectionObserver((entries) => {
    onScreen = entries.at(-1)!.isIntersecting;
    schedule();
  }).observe(root);
  document.addEventListener('visibilitychange', schedule);
}
