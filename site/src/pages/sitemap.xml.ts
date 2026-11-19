// Every page, for search engines.
import { site } from '../config.ts';
import { content } from '../content/repository.ts';

export function GET() {
  const urls = content()
    .routes.map((r) => `  <url><loc>${site.url}${r === '/' ? '/' : r}</loc></url>`)
    .join('\n');
  return new Response(`<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls}\n</urlset>\n`, {
    headers: { 'Content-Type': 'application/xml' },
  });
}
