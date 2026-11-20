// Markdown → HTML, at build time. Everything heavy happens here, once:
// syntax highlighting (Shiki), image sizes and WebP variants, link rewriting,
// heading anchors. Pages ship finished HTML.
import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';
import remarkRehype from 'remark-rehype';
import rehypeRaw from 'rehype-raw';
import rehypeShiki from '@shikijs/rehype';
import rehypeStringify from 'rehype-stringify';
import { visit, SKIP } from 'unist-util-visit';
import { toString } from 'hast-util-to-string';
import type { Element, ElementContent, Root, Parent } from 'hast';
import { site } from '../config.ts';
import { iconSvg } from './icons.ts';
import { image } from './media.ts';
import { loopVideo, loopVideoHtml } from './video.ts';
import { preprocess } from './markdown-source.ts';
import { content, resolveAsset } from './repository.ts';
import { escapeHtml, isExternal, slugify } from './text.ts';
import type { IconName } from '../config.ts';

export interface Heading {
  level: 2 | 3;
  id: string;
  text: string;
}

export interface Rendered {
  html: string;
  /** Top-level h2/h3 headings in order, for "On this page". */
  headings: Heading[];
  /** The page has a ```mermaid diagram (its script then loads on that page only). */
  mermaid: boolean;
}

interface Options {
  /** The .md file, from the repository root: relative links and images resolve against it. */
  sourcePath: string;
  /** Buttons for `::plugin-links`. */
  links?: Record<string, string>;
  /** The widest images are shown, in CSS pixels. */
  imageWidth?: number;
}

const calloutLook: Record<string, [IconName, string]> = {
  note: ['note', 'Note'],
  tip: ['tip', 'Tip'],
  info: ['info', 'Info'],
  warning: ['warning', 'Warning'],
  danger: ['danger', 'Danger'],
};

/** Short names people type after ``` mapped to Shiki language ids. */
const languageAliases: Record<string, string> = {
  'c++': 'cpp', cc: 'cpp', h: 'cpp', hpp: 'cpp', ue: 'cpp', unreal: 'cpp',
  'c#': 'csharp', cs: 'csharp', sh: 'bash', shell: 'bash', zsh: 'bash', console: 'bash',
  yml: 'yaml', js: 'javascript', ts: 'typescript', py: 'python', ini: 'ini', cfg: 'ini',
  txt: 'text', plain: 'text', plaintext: 'text',
};
const languages = ['cpp', 'c', 'csharp', 'json', 'yaml', 'bash', 'ini', 'python', 'javascript', 'typescript', 'html', 'css', 'markdown', 'xml'];
const languageNames: Record<string, string> = { cpp: 'C++', csharp: 'C#', javascript: 'JavaScript', typescript: 'TypeScript', json: 'JSON', yaml: 'YAML', bash: 'Shell', ini: 'INI', python: 'Python', html: 'HTML', css: 'CSS', xml: 'XML', c: 'C', markdown: 'Markdown' };

const raw = (value: string) => ({ type: 'raw', value }) as unknown as ElementContent;
const cls = (node: Element) => {
  // Markdown's nodes name it `className`; Shiki's own <pre> names it `class`.
  const c = node.properties?.className ?? node.properties?.class;
  return Array.isArray(c) ? c.map(String) : typeof c === 'string' ? c.split(' ') : [];
};

export function linkButtons(links: Record<string, string>): string {
  const entries = Object.entries(links);
  if (entries.length === 0) return '';
  const look = (key: string): [IconName, string] =>
    (({ fab: ['store', 'Get it on Fab'], github: ['github', 'GitHub'], youtube: ['youtube', 'YouTube'] }) as Record<string, [IconName, string]>)[key] ??
    ['external', key[0].toUpperCase() + key.slice(1)];
  return `<div class="button-row">${entries
    .map(([key, url], i) => {
      const [icon, label] = look(key);
      return `<a class="button ${i === 0 && key === 'fab' ? 'button-filled' : 'button-outlined'}" href="${escapeHtml(url)}" target="_blank" rel="noopener">${iconSvg(icon)}<span>${escapeHtml(label)}</span></a>`;
    })
    .join('')}</div>`;
}

export function youtubeFacade(videoId: string, start?: number, title = 'YouTube video'): string {
  const id = escapeHtml(videoId);
  const watch = `https://www.youtube.com/watch?v=${id}${start ? `&t=${start}s` : ''}`;
  return (
    `<div class="youtube" data-video="${id}"${start ? ` data-start="${start}"` : ''}>` +
    `<a class="youtube-poster" href="${watch}" target="_blank" rel="noopener" aria-label="Play: ${escapeHtml(title)}">` +
    `<img src="https://i.ytimg.com/vi/${id}/hqdefault.jpg" alt="" width="480" height="360" loading="lazy" decoding="async">` +
    `<span class="youtube-play">${iconSvg('play')}</span></a></div>`
  );
}

function sitePlugin(options: Options, state: { headings: Heading[]; mermaid: boolean }) {
  const repo = content();
  return async (tree: Root) => {
    const images: { node: Element; parent: Parent; index: number }[] = [];
    const videos: { args: string; parent: Parent; index: number }[] = [];
    const ids = new Map<string, number>();

    visit(tree, 'element', (node: Element, index, parent) => {
      const p = node.properties ?? {};

      if (node.tagName === 'aside' && p.dataCallout) {
        const type = String(p.dataCallout);
        const [icon, label] = calloutLook[type] ?? calloutLook.note;
        const title = p.dataTitle ? String(p.dataTitle) : label;
        node.children.unshift(raw(`<p class="callout-title">${iconSvg(icon)}<span>${escapeHtml(title)}</span></p>`));
        delete p.dataCallout;
        delete p.dataTitle;
        // Headings inside callouts aren't part of "On this page".
        return;
      }

      if (node.tagName === 'div' && p.dataYoutube && parent && index != null) {
        parent.children[index] = raw(youtubeFacade(String(p.dataYoutube), p.dataStart ? Number(p.dataStart) : undefined));
        return SKIP;
      }

      if (node.tagName === 'div' && p.dataDirective && parent && index != null) {
        const name = String(p.dataDirective);
        if (name === 'video') {
          videos.push({ args: String(p.dataArgs ?? ''), parent, index });
          return SKIP;
        }
        parent.children[index] =
          name === 'plugin-links'
            ? raw(linkButtons(options.links ?? {}))
            : raw(`<p class="unknown-directive">Unknown directive ::${escapeHtml(name)}</p>`);
        return SKIP;
      }

      if ((node.tagName === 'h2' || node.tagName === 'h3') && parent?.type === 'root') {
        const text = toString(node).trim();
        const base = slugify(text, { stripNumberPrefix: false }) || 'section';
        const count = ids.get(base) ?? 0;
        ids.set(base, count + 1);
        const id = count === 0 ? base : `${base}-${count}`;
        node.properties = { ...p, id };
        node.children.push(raw(`<a class="anchor" href="#${id}" aria-label="Link to this section">#</a>`));
        state.headings.push({ level: node.tagName === 'h2' ? 2 : 3, id, text });
        return;
      }

      if (node.tagName === 'a' && typeof p.href === 'string') {
        const href = p.href;
        if (isExternal(href)) {
          if (!href.startsWith('mailto:') && !href.startsWith('tel:')) {
            p.target = '_blank';
            p.rel = 'noopener';
          }
        } else if (/\.(pdf|zip)$/i.test(href.split('#')[0])) {
          p.target = '_blank';
        } else {
          const route = repo.internalRoute(href, options.sourcePath);
          if (route != null) p.href = route;
        }
        return;
      }

      if (node.tagName === 'img' && parent && index != null) {
        images.push({ node, parent, index });
        return;
      }

      if (node.tagName === 'pre' && parent && index != null) {
        const code = node.children.find((c): c is Element => c.type === 'element' && c.tagName === 'code');
        if (code && cls(code).includes('language-mermaid')) {
          state.mermaid = true;
          parent.children[index] = raw(`<pre class="mermaid">${escapeHtml(toString(code))}</pre>`);
          return SKIP;
        }
        if (code) {
          // Normalise the language for Shiki; unknown ones are shown as plain text.
          const lang = cls(code).find((c) => c.startsWith('language-'))?.slice('language-'.length).toLowerCase();
          const id = lang ? (languageAliases[lang] ?? lang) : 'text';
          code.properties = { ...code.properties, className: [`language-${languages.includes(id) ? id : 'text'}`] };
          node.properties = { ...node.properties, dataLang: lang ?? '' };
        }
        return;
      }

      if (node.tagName === 'table' && parent && index != null) {
        parent.children[index] = { type: 'element', tagName: 'div', properties: { className: ['table-wrap'] }, children: [node] };
        return SKIP;
      }
    });

    const width = options.imageWidth ?? 780;

    // `::video ./clip.mp4 Caption`: a silent clip that loops, with the caption under it.
    await Promise.all(
      videos.map(async ({ args, parent, index }) => {
        const [src = '', ...rest] = args.split(/\s+/);
        const caption = rest.join(' ').replace(/^["'](.*)["']$/, '$1').trim();
        const video = src ? await loopVideo(resolveAsset(options.sourcePath, src), width) : null;
        parent.children[index] = raw(
          video
            ? `<figure class="loop-figure">${loopVideoHtml(video, { label: caption || undefined })}${caption ? `<figcaption>${escapeHtml(caption)}</figcaption>` : ''}</figure>`
            : `<span class="broken-image" title="Video not found: ${escapeHtml(src)}">${iconSvg('file')} ${escapeHtml(caption || src || '::video needs a file')}</span>`,
        );
      }),
    );

    // Images: real sizes (no layout shift), WebP variants, lazy loading, and a click to enlarge.
    await Promise.all(
      images.map(async ({ node, parent, index }) => {
        const src = String(node.properties?.src ?? '');
        const alt = String(node.properties?.alt ?? '');
        const info = await image(resolveAsset(options.sourcePath, src), width);
        if (!info) {
          parent.children[index] = raw(`<span class="broken-image" title="Image not found: ${escapeHtml(src)}">${iconSvg('file')} ${escapeHtml(alt || src)}</span>`);
          return;
        }
        const large = info.srcset ? info.srcset.split(', ').at(-1)!.split(' ')[0] : info.src;
        const attrs = [
          `src="${info.src}"`,
          info.srcset ? `srcset="${info.srcset}" sizes="(max-width: ${width + 64}px) 100vw, ${width}px"` : '',
          info.width ? `width="${info.width}" height="${info.height}"` : '',
          `alt="${escapeHtml(alt)}"`,
          'loading="lazy" decoding="async"',
        ].filter(Boolean);
        parent.children[index] = raw(`<a class="zoomable" href="${large}" data-zoom>${`<img ${attrs.join(' ')}>`}</a>`);
      }),
    );
  };
}

/** Wraps each highlighted code block with its language and a copy button. */
function codeFrames() {
  return (tree: Root) => {
    visit(tree, 'element', (node: Element, index, parent) => {
      if (node.tagName !== 'pre' || !parent || index == null || !cls(node).includes('shiki')) return;
      const lang = String(node.properties?.dataLang ?? '');
      const id = languageAliases[lang] ?? lang;
      const label = lang ? (languageNames[id] ?? lang.toUpperCase()) : 'Code';
      delete node.properties.dataLang;
      delete node.properties.style;
      node.properties.tabIndex = 0;
      parent.children[index] = {
        type: 'element',
        tagName: 'figure',
        properties: { className: ['code'] },
        children: [
          raw(`<figcaption><span>${escapeHtml(label)}</span><button type="button" class="code-copy" data-copy aria-label="Copy code">${iconSvg('copy')}<span>Copy</span></button></figcaption>`),
          node,
        ],
      };
      return SKIP;
    });
  };
}

const cache = new Map<string, Promise<Rendered>>();

/** [markdown] (a file body) as HTML, with its headings. Cached per file. */
export function render(markdown: string, options: Options): Promise<Rendered> {
  const key = `${options.sourcePath}\u0000${options.links ? JSON.stringify(options.links) : ''}\u0000${markdown}`;
  let hit = cache.get(key);
  if (!hit) {
    hit = (async () => {
      const state = { headings: [] as Heading[], mermaid: false };
      const file = await unified()
        .use(remarkParse)
        .use(remarkGfm)
        .use(remarkRehype, { allowDangerousHtml: true })
        .use(rehypeRaw)
        .use(() => sitePlugin(options, state))
        .use(rehypeShiki, {
          themes: { light: 'github-light', dark: 'one-dark-pro' },
          defaultColor: false,
          langs: languages,
          fallbackLanguage: 'text',
          defaultLanguage: 'text',
          // Shiki makes a new <pre>; carry the language over for the code frame's label.
          transformers: [
            {
              pre(node) {
                node.properties.dataLang = this.options.lang === 'text' ? '' : this.options.lang;
              },
            },
          ],
        })
        .use(codeFrames)
        .use(rehypeStringify, { allowDangerousHtml: true })
        .process(preprocess(markdown));
      return { html: String(file), headings: state.headings, mermaid: state.mermaid };
    })();
    cache.set(key, hit);
  }
  return hit;
}

export { site };
