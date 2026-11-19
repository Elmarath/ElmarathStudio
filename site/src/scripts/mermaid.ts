// Draws ```mermaid diagrams. The library (large) is loaded only on pages that
// have one, once the page is idle, and the diagrams follow the theme.
export function drawDiagrams(signal: AbortSignal) {
  const blocks = document.querySelectorAll<HTMLElement>('pre.mermaid');
  if (blocks.length === 0) return;
  const sources = [...blocks].map((b) => b.textContent ?? '');
  const draw = async () => {
    const { default: mermaid } = await import('mermaid');
    const dark = document.documentElement.dataset.theme !== 'elmarath-gold';
    mermaid.initialize({ startOnLoad: false, theme: dark ? 'dark' : 'neutral', securityLevel: 'strict', fontFamily: 'inherit' });
    blocks.forEach((b, i) => {
      b.removeAttribute('data-processed');
      b.textContent = sources[i];
    });
    await mermaid.run({ nodes: [...blocks] });
  };
  const idle = (window as unknown as { requestIdleCallback?: (cb: () => void) => void }).requestIdleCallback ?? ((cb: () => void) => setTimeout(cb, 200));
  idle(() => void draw());
  // Redraw in the other theme's colors when the theme changes.
  const themes = new MutationObserver(() => void draw());
  themes.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
  signal.addEventListener('abort', () => themes.disconnect());
}
