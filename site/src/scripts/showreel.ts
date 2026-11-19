// The home page showreel: the clips play one after another on a loop, only
// while the video is on screen (off screen it would still cost decoding), and
// not at all with "reduce motion" on. The glow cross-fades to each clip's colours.
export function startShowreel() {
  const reel = document.querySelector<HTMLElement>('[data-showreel]');
  const video = reel?.querySelector('video');
  if (!reel || !video) return;
  const clips: string[] = JSON.parse(reel.dataset.clips ?? '[]');
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
    update();
  };
  video.addEventListener('ended', () => {
    video.classList.add('swapping');
    setTimeout(() => show(clip + 1), 350);
  });
  video.addEventListener('playing', () => video.classList.remove('swapping'));
  new IntersectionObserver((entries) => {
    visible = entries.at(-1)!.isIntersecting;
    update();
  }).observe(video);
  document.addEventListener('visibilitychange', update);
}
