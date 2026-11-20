// The silent looping clips (`<video data-loop>`, from src/content/video.ts):
// each one plays, on repeat, whenever it's on screen. Nothing loads until a
// clip comes near the screen, and a clip scrolled out of sight pauses, so
// only the ones you can see use the network, battery and decoder.
//
// They have no sound, so they play regardless of the visitor's motion setting
// and have no controls. If the browser holds one back (iPhone Low Power Mode
// blocks autoplay; a tab in the background pauses video), it starts again on
// the next tap or when the tab is shown again.
import { observe, onPage } from './lifecycle.ts';

// The page-to-page transition still animates when a new page starts, and
// Safari can report the clips as off screen until it ends. Nothing moves after
// that, so no change would come: the clips are looked at again once it's done.
let transition: { finished: Promise<unknown> } | undefined;
document.addEventListener('astro:before-swap', (e) => {
  transition = (e as Event & { viewTransition?: { finished: Promise<unknown> } }).viewTransition;
});

onPage((signal) => {
  const videos = [...document.querySelectorAll<HTMLVideoElement>('video[data-loop]')];
  if (videos.length === 0) return;
  const visible = new Set<HTMLVideoElement>();

  // A clip that's refused while the new page is still settling in is tried
  // again a few times; one that keeps being refused waits for a tap.
  const play = (v: HTMLVideoElement, tries = 4) => {
    v.muted = true; // as a property too: some browsers only trust that for autoplay
    if (!v.paused) return;
    v.play().catch(() => {
      if (tries > 0) setTimeout(() => signal.aborted || !visible.has(v) || play(v, tries - 1), 400);
    });
  };
  const resume = () => visible.forEach((v) => play(v));

  const observer = observe(
    signal,
    videos,
    (entries) => {
      for (const { target, isIntersecting } of entries) {
        const v = target as HTMLVideoElement;
        if (isIntersecting) {
          visible.add(v);
          play(v);
        } else {
          visible.delete(v);
          v.pause();
        }
      }
    },
    // Start a little before it scrolls in, so it's already moving when seen.
    { rootMargin: '200px 0px' },
  );
  // Observing again reports where each clip is now.
  transition?.finished
    .catch(() => {})
    .then(() => {
      if (signal.aborted) return;
      for (const v of videos) {
        observer.unobserve(v);
        observer.observe(v);
      }
    });
  transition = undefined;

  document.addEventListener('visibilitychange', () => document.hidden || resume(), { signal });
  document.addEventListener('pointerdown', resume, { signal, passive: true });
  signal.addEventListener('abort', () => videos.forEach((v) => v.pause()));
});
