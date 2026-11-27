// The website editor's settings, made from the docs tree (src/content/cms.ts).
import { cmsConfig } from '../../content/cms.ts';
import { content } from '../../content/repository.ts';

export function GET() {
  return new Response(cmsConfig(content().categories), { headers: { 'Content-Type': 'text/yaml; charset=utf-8' } });
}
