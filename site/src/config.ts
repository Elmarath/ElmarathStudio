// Everything about *you* and the site's structure lives here.
//
// Change a name, link or menu item in this file and the whole site updates.
// Blog posts, docs, pages and case studies are Markdown files in ../content,
// not here.

export interface NavItem {
  label: string;
  /** A site route (`/docs`) or an external URL (`https://…`, `mailto:…`). */
  path: string;
}

export interface SocialLink {
  label: string;
  url: string;
  icon: IconName;
}

export type IconName =
  | 'github'
  | 'linkedin'
  | 'discord'
  | 'youtube'
  | 'x'
  | 'mail'
  | 'store'
  | 'doc'
  | 'book'
  | 'search'
  | 'palette'
  | 'menu'
  | 'close'
  | 'arrow-right'
  | 'arrow-left'
  | 'chevron-right'
  | 'play'
  | 'pause'
  | 'download'
  | 'external'
  | 'copy'
  | 'check'
  | 'rocket'
  | 'folder'
  | 'file'
  | 'puzzle'
  | 'grid'
  | 'edit'
  | 'star'
  | 'note'
  | 'tip'
  | 'info'
  | 'warning'
  | 'danger'
  | 'article'
  | 'work'
  | 'check-circle'
  | 'globe'
  | 'gamepad'
  | 'code'
  | 'map-pin'
  | 'calendar'
  | 'users'
  | 'trending-up'
  | 'cpu'
  | 'building'
  | 'sparkles'
  | 'quote'
  | 'milestone'
  | 'layers';

const email = 'toprakdenizhan19@gmail.com';

export const site = {
  name: 'Elmarath',
  /** Where the site is published: used for canonical links, the sitemap and link previews. */
  url: 'https://elmarath.com',
  /** Netlify's own address for the site: it redirects to `url`, so search engines see the site once. */
  netlifyHost: 'elmarathstudio.netlify.app',
  ownerName: 'Denizhan Toprak',
  role: 'C++ Gameplay Programmer',
  avatarUrl: 'https://avatars.githubusercontent.com/u/65414809?v=4',
  /** Paths below are files in `public/`, served as they are. */
  logo: '/brand/logo.png',
  /** The image shown in link previews (Discord, LinkedIn, X...). */
  shareImage: '/brand/hero.jpeg',
  email,
  /** Google Analytics. Set to null to turn analytics off. */
  analyticsId: 'G-CRZ373MY93' as string | null,

  // Home page hero. A non-breaking space keeps "Unreal Engine" together when the line wraps.
  heroTitle: 'Gameplay systems,\nbuilt for Unreal Engine.',
  heroSubtitle:
    "I’m Denizhan, a C++ Gameplay Programmer specializing in Unreal Engine.\n" +
    'I build gameplay systems, develop modular and production-ready plugins.\n' +
    'Also I document my work to share the technical knowledge and experiences behind each project here!',

  /**
   * The showreel next to the hero text: short, muted clips that play one after
   * another on a loop. Put them in public/videos/, each with a still of the same
   * name ending in `.jpg`, shown until the clip can play and used for its glow.
   * Make each one with `npm run video -- <export> public/videos/<name>.mp4 --size card`;
   * its smaller `.av1.mp4` copy is used where the browser can play it. (Keep the
   * old `.jpg` if you want the same glow: the command writes a new one.)
   * The "Now playing" label comes from the file name; give an entry as
   * `{ src, label }` to write it yourself.
   */
  heroVideos: [
    '/videos/skeletal-mesh-merge.mp4',
    '/videos/trace-trail.mp4',
    '/videos/staged-interaction-system.mp4',
    '/videos/easy-game-user-settings.mp4',
    { src: '/videos/crafting-ability-and-ui.mp4', label: 'Crafting ability and UI' },
  ] as (string | { src: string; label?: string })[],

  /**
   * The portfolio: case studies from ../content/work at /work, a Work tab in
   * the nav and a "Selected work" section on the home page. Off until the case
   * studies are written; set to true to show all of it.
   */
  showWork: true,

  /** The call-to-action button at the right of the nav bar. */
  storeLink: { label: 'Fab Store', url: 'https://www.fab.com/sellers/Elmarath' },

  /** Your CV. Links to `resumeUrl` open it in a viewer window; `/cv` shows it as a page. */
  cvFile: '/files/DenizhanToprak_Resume.pdf',
  resumeUrl: '/cv',

  /**
   * Repository for "Edit this page" links on docs, e.g.
   * 'https://github.com/Elmarath/ElmarathStudio/edit/master/'. Null hides the link.
   */
  editBaseUrl: null as string | null,

  /**
   * Old addresses that moved somewhere else entirely, so links to them keep
   * working. Letter case, spaces and dashes don't matter. Old docs and blog
   * URLs from the Docusaurus site are matched automatically.
   */
  movedPages: {
    '/docs/PrivacyPolicy': '/privacy-policy',
    '/blog/About Me': '/about',
    '/blog/archive': '/blog',
    '/blog/authors': '/blog',
    '/blog/tags': '/blog',
    '/docs/Ability-Queue-Task-System/UseCaseExample copy': '/docs/ability-queue-task-system/use-case-example',
    // Docusaurus template pages.
    '/helloReact': '/',
    '/markdown-page': '/',
  } as Record<string, string>,

  /** Social links: shown in the footer, the About page and the nav drawer. */
  socials: [
    { label: 'GitHub', url: 'https://github.com/Elmarath', icon: 'github' },
    { label: 'LinkedIn', url: 'https://www.linkedin.com/in/denizhan-toprak-006073193/', icon: 'linkedin' },
    { label: 'Discord', url: 'https://discord.gg/mUm4hYvG3x', icon: 'discord' },
    { label: 'YouTube', url: 'https://www.youtube.com/channel/UCVE1fkgWSSXIa-jZFVdDsaQ', icon: 'youtube' },
    { label: 'X', url: 'https://twitter.com/denizhan_toprak', icon: 'x' },
  ] as SocialLink[],
};

/** Main navigation, left to right. */
export const navItems: NavItem[] = [
  { label: 'Home', path: '/' },
  ...(site.showWork ? [{ label: 'Work', path: '/work' }] : []),
  { label: 'Docs', path: '/docs' },
  { label: 'Blog', path: '/blog' },
  { label: 'About', path: '/about' },
];

/** Footer link columns. */
export const footerColumns: { title: string; links: NavItem[] }[] = [
  {
    title: 'Explore',
    links: [
      { label: 'Documentation', path: '/docs' },
      { label: 'Blog', path: '/blog' },
      { label: 'About me', path: '/about' },
    ],
  },
  {
    title: 'Contact',
    links: [
      { label: 'Email', path: `mailto:${email}` },
      { label: 'Resume / CV', path: site.resumeUrl },
      { label: 'Fab Store', path: site.storeLink.url },
    ],
  },
  { title: 'Legal', links: [{ label: 'Privacy Policy', path: '/privacy-policy' }] },
];

/**
 * The themes in the theme menu. The first is the default. Colors live in
 * src/styles/themes.css under `[data-theme="<id>"]`; add a block there and an
 * entry here to make a new one.
 */
export const themes = [
  { id: 'elmarath-dark', name: 'Forge (dark)', background: '#0D0C0A', accent: '#E3AA3E', dark: true },
  { id: 'elmarath-gold', name: 'Parchment (light)', background: '#F6F1E8', accent: '#9A6210', dark: false },
] as const;

export type ThemeId = (typeof themes)[number]['id'];
