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

onPage((signal) => {
  const videos = [...document.querySelectorAll<HTMLVideoElement>('video[data-loop]')];
  if (videos.length === 0) return;
  const visible = new Set<HTMLVideoElement>();

  const play = (v: HTMLVideoElement) => {
    v.muted = true; // as a property too: some browsers only trust that for autoplay
    if (v.paused) v.play().catch(() => {});
  };
  const resume = () => visible.forEach(play);

  observe(
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

  document.addEventListener('visibilitychange', () => document.hidden || resume(), { signal });
  document.addEventListener('pointerdown', resume, { signal, passive: true });
  signal.addEventListener('abort', () => videos.forEach((v) => v.pause()));
});
