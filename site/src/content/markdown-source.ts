// The site's Markdown extensions, turned into plain Markdown plus a few HTML
// placeholders before the Markdown is rendered (see markdown.ts). A port of the
// Flutter site's block parser (lib/content/markdown_blocks.dart).
//
// * `:::note Title` … `:::` (Docusaurus admonitions, nestable) and GitHub's
//   `> [!NOTE]` alerts → a callout box
// * `::youtube <id or url> [start=90]` or a YouTube `<iframe>` → a video that
//   loads only when played
// * `::video ./clip.mp4 Caption` → a silent clip that loops (made by `npm run video`)
// * `::plugin-links` → the plugin's Fab / GitHub buttons
// * `<!-- truncate -->` (the blog excerpt marker) and MDX imports are dropped
// * `<!-- TODO … -->` notes never reach the page: dropped, or shown as a "....."
//   placeholder on docs marked `wip: true`
import { escapeHtml } from './text.ts';

export interface Youtube {
  videoId: string;
  start?: number;
}

const admonitionTypes: Record<string, string> = {
  note: 'note',
  tip: 'tip',
  info: 'info',
  important: 'info',
  warning: 'warning',
  caution: 'warning',
  danger: 'danger',
};

const fenceRe = /^\s*(```|~~~)/;
const admonitionStart = /^\s*:::\s*([a-zA-Z]+)\s*(.*)$/;
const admonitionEnd = /^\s*:::\s*$/;
const githubAlert = /^\s*>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*$/i;
const directiveRe = /^::([a-zA-Z][\w-]*)\s*(.*)$/;
const youtubeIframe = /<iframe[^>]+youtube(?:-nocookie)?\.com\/embed\/([\w-]+)([^"']*)/;
const mdxImport = /^import\s+.+\s+from\s+['"].+['"];?\s*$/;
const todoStart = /^\s*<!--\s*TODO\b/i;

export interface PreprocessOptions {
  /** Show each `<!-- TODO … -->` as a "....." placeholder instead of dropping it (work-in-progress docs). */
  todoPlaceholders?: boolean;
}

const todoPlaceholder = '<p class="todo-placeholder" aria-label="Coming soon" title="Coming soon">.....</p>';

/** A YouTube video from a link or id, with an optional `start=90` after it. */
export function parseYoutube(args: string): Youtube | undefined {
  const parts = args.trim().split(/\s+/);
  if (parts.length === 0 || parts[0] === '') return undefined;
  const source = parts[0];
  let id: string | undefined;
  let start: number | undefined;
  try {
    const uri = new URL(source);
    id = uri.searchParams.get('v') ?? (uri.host.includes('youtu.be') ? uri.pathname.split('/').filter(Boolean)[0] : uri.pathname.split('/').filter(Boolean).at(-1));
    const t = (uri.searchParams.get('t') ?? uri.searchParams.get('start') ?? '').replace('s', '');
    start = t ? Number.parseInt(t, 10) || undefined : undefined;
  } catch {
    id = source;
  }
  for (const p of parts.slice(1)) {
    const m = /^(?:start|t)=(\d+)/.exec(p);
    if (m) start = Number(m[1]);
  }
  return id ? { videoId: id, start } : undefined;
}

const youtubeHtml = (v: Youtube) =>
  `<div data-youtube="${escapeHtml(v.videoId)}"${v.start ? ` data-start="${v.start}"` : ''}></div>`;

function dedent(lines: string[]): string[] {
  const indents = lines.filter((l) => l.trim()).map((l) => /^\s*/.exec(l)![0].length);
  const min = indents.length ? Math.min(...indents) : 0;
  return lines.map((l) => l.slice(Math.min(min, /^\s*/.exec(l)![0].length)));
}

const cleanTitle = (raw?: string) => {
  const t = raw?.replace(/\*/g, '').trim();
  return t ? t : undefined;
};

/** Turns the site's extensions in [source] into Markdown the renderer understands. */
export function preprocess(source: string, options: PreprocessOptions = {}): string {
  return transform(source.replace(/\r\n/g, '\n').split('\n'), options).join('\n');
}

function transform(lines: string[], options: PreprocessOptions): string[] {
  const out: string[] = [];
  let inFence = false;
  let fenceMarker = '';

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const fence = fenceRe.exec(line);
    if (fence) {
      if (!inFence) {
        inFence = true;
        fenceMarker = fence[1];
      } else if (line.trim().startsWith(fenceMarker)) {
        inFence = false;
      }
      out.push(line);
      continue;
    }
    if (inFence) {
      out.push(line);
      continue;
    }
    if (line.trim() === '<!-- truncate -->' || mdxImport.test(line.trim())) continue;

    if (todoStart.test(line)) {
      while (!lines[i].includes('-->') && i + 1 < lines.length) i++;
      if (options.todoPlaceholders) out.push('', todoPlaceholder, '');
      continue;
    }

    const admonition = admonitionStart.exec(line);
    if (admonition && admonitionTypes[admonition[1].toLowerCase()]) {
      const inner: string[] = [];
      let depth = 1;
      let innerFence = false;
      for (i++; i < lines.length; i++) {
        const l = lines[i];
        if (fenceRe.test(l)) innerFence = !innerFence;
        if (!innerFence) {
          if (admonitionEnd.test(l)) {
            if (--depth === 0) break;
          } else if (admonitionStart.test(l)) {
            depth++;
          }
        }
        inner.push(l);
      }
      out.push(...callout(admonitionTypes[admonition[1].toLowerCase()], cleanTitle(admonition[2]), transform(dedent(inner), options)));
      continue;
    }

    const alert = githubAlert.exec(line);
    if (alert) {
      const inner: string[] = [];
      while (i + 1 < lines.length && lines[i + 1].trimStart().startsWith('>')) {
        i++;
        inner.push(lines[i].trimStart().replace(/^>\s?/, ''));
      }
      out.push(...callout(admonitionTypes[alert[1].toLowerCase()], undefined, transform(inner, options)));
      continue;
    }

    const iframe = youtubeIframe.exec(line);
    if (iframe) {
      const start = /start=(\d+)/.exec(iframe[2] ?? '');
      out.push('', youtubeHtml({ videoId: iframe[1], start: start ? Number(start[1]) : undefined }), '');
      continue;
    }

    const directive = directiveRe.exec(line.trim());
    if (directive) {
      const name = directive[1].toLowerCase();
      const args = directive[2].trim();
      const youtube = name === 'youtube' ? parseYoutube(args) : undefined;
      out.push(
        '',
        youtube ? youtubeHtml(youtube) : `<div data-directive="${escapeHtml(name)}" data-args="${escapeHtml(args)}"></div>`,
        '',
      );
      continue;
    }
    out.push(line);
  }
  return out;
}

/**
 * A callout box. The blank lines around the content let Markdown inside it
 * render as Markdown (an HTML block ends at the first blank line).
 */
function callout(type: string, title: string | undefined, inner: string[]): string[] {
  return [
    '',
    `<aside class="callout callout-${type}" data-callout="${type}"${title ? ` data-title="${escapeHtml(title)}"` : ''}>`,
    '',
    ...inner,
    '',
    '</aside>',
    '',
  ];
}
