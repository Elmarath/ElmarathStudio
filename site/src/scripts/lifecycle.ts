// Pages are swapped in place by the client router (no full reload), and a
// script runs only the first time it's loaded. So page code starts from here:
// [setup] runs on every page (the first one and each one swapped in), and
// [signal] aborts when that page is swapped out, to stop its timers,
// observers and listeners.
export function onPage(setup: (signal: AbortSignal) => void) {
  let controller: AbortController | undefined;
  const start = () => {
    controller?.abort();
    controller = new AbortController();
    setup(controller.signal);
  };
  document.addEventListener('astro:page-load', start);
  document.addEventListener('astro:before-swap', () => controller?.abort());
}

/** An IntersectionObserver that stops with [signal]. */
export function observe(
  signal: AbortSignal,
  targets: Element | Element[],
  callback: IntersectionObserverCallback,
  options?: IntersectionObserverInit,
) {
  const observer = new IntersectionObserver(callback, options);
  for (const t of Array.isArray(targets) ? targets : [targets]) observer.observe(t);
  signal.addEventListener('abort', () => observer.disconnect());
  return observer;
}
