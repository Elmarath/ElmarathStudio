// How a Work entry's links are labelled: the key written under `links:` picks
// the icon and the words ("fab" → "Get it on Fab").
import type { IconName } from '../config.ts';
import type { CaseStudy } from './repository.ts';
import { isExternal } from './text.ts';

export function linkLook(key: string): [IconName, string] {
  switch (key.toLowerCase()) {
    case 'reel': case 'youtube': case 'video': case 'trailer': return ['youtube', 'Watch the reel'];
    case 'github': case 'repo': case 'repository': return ['github', 'Repository'];
    case 'fab': return ['store', 'Get it on Fab'];
    case 'steam': return ['gamepad', 'Steam page'];
    case 'itch': return ['gamepad', 'Play on itch.io'];
    case 'docs': return ['book', 'Documentation'];
    case 'website': case 'site': case 'company': return ['globe', 'Website'];
    case 'devlog': case 'blog': return ['article', 'Devlog'];
    case 'projects': case 'portfolio': return ['external', 'See the projects'];
    case 'plugins': return ['store', 'My plugins on Fab'];
    case 'jam': return ['calendar', 'The jam'];
    case 'press': case 'article': return ['article', 'In the press'];
    default: return ['external', key[0].toUpperCase() + key.slice(1)];
  }
}

/** The entry's one main link (the first under `links:`), labelled. */
export function mainLink(study: CaseStudy): { url: string; icon: IconName; label: string; external: boolean } | undefined {
  const first = Object.entries(study.links)[0];
  if (!first) return undefined;
  const [icon, label] = linkLook(first[0]);
  return { url: first[1], icon, label, external: isExternal(first[1]) };
}
