// The home page showreel: the clips play one after another on a loop, only
// while the video is on screen (off screen it would still cost decoding), and
// not at all with "reduce motion" on. The glow cross-fades to each clip's colours.
// Everything stops with [signal] (the page being swapped out).
import { observe } from './lifecycle.ts';

export function startShowreel(signal: AbortSignal) {
  const reel = document.querySelector<HTMLElement>('[data-showreel]');
  const video = reel?.querySelector('video');
  if (!reel || !video) return;
  const clips: string[] = JSON.parse(reel.dataset.clips ?? '[]');
  const labels: string[] = JSON.parse(reel.dataset.labels ?? '[]');
  const label = reel.querySelector('[data-clip-label]');
  const count = reel.querySelector('[data-clip-count]');
  const darkGlows = reel.querySelectorAll('.glow .dark');
  const brightGlows = reel.querySelectorAll('.glow .bright');
  const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;
  let clip = 0;
  let visible = false;

  video.loop = clips.length === 1;
  const update = () => {
    if (visible && !reduceMotion && !document.hidden) video.play().catch(() => {}); // autoplay can be blocked, e.g. in Low Power Mode
    else video.pause();
  };
  const show = (index: number) => {
    clip = index % clips.length;
    video.poster = clips[clip].replace(/\.\w+$/, '.jpg');
    video.src = clips[clip];
    darkGlows.forEach((g, i) => g.classList.toggle('on', i === clip));
    brightGlows.forEach((g, i) => g.classList.toggle('on', i === clip));
    if (label) label.textContent = labels[clip] ?? '';
    if (count) count.textContent = `${String(clip + 1).padStart(2, '0')} / ${String(clips.length).padStart(2, '0')}`;
    update();
  };
  video.addEventListener('ended', () => {
    video.classList.add('swapping');
    const next = setTimeout(() => show(clip + 1), 350);
    signal.addEventListener('abort', () => clearTimeout(next));
  }, { signal });
  video.addEventListener('playing', () => video.classList.remove('swapping'), { signal });
  observe(signal, video, (entries) => {
    visible = entries.at(-1)!.isIntersecting;
    update();
  });
  document.addEventListener('visibilitychange', update, { signal });
  signal.addEventListener('abort', () => video.pause());
}
