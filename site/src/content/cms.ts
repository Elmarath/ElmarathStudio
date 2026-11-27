// The website editor's settings (Sveltia CMS at /admin): which Markdown files
// it can open, and where it commits them. Made at build time from the docs
// tree, so a new plugin folder shows up in the editor without touching this.
import { stringify } from 'yaml';
import type { DocCategory } from './repository.ts';

/** GitHub repository and branch the editor reads and commits to. */
export const cmsRepo = { repo: 'Elmarath/ElmarathStudio', branch: 'master' };

// Every body is edited as plain Markdown source ("raw"), never through the
// rich text editor: that would rewrite the site's extras (`:::note` callouts,
// `::youtube`, `::video`, `::plugin-links`) and reformat lists and tables.
const body = { name: 'body', label: 'Content', widget: 'richtext', modes: ['raw'] };
const optional = (name: string, label: string, widget = 'string', extra: Record<string, unknown> = {}) => ({
  name,
  label,
  widget,
  required: false,
  ...extra,
});

// Front matter the docs use (see parseDocs in repository.ts), in the order the
// files already have it. Keys not listed here are kept as they are.
const docFields = [
  optional('id', 'ID (sets the URL; defaults to the file name)'),
  optional('title', 'Title (defaults to the first # heading)'),
  optional('sidebar_label', 'Sidebar label'),
  optional('sidebar_position', 'Sidebar position', 'number', { value_type: 'int' }),
  optional('description', 'Description', 'text'),
  body,
];

/** A folder of Markdown files whose images live in `img/` next to them, linked as `img/name.png`. */
const folder = (name: string, label: string, dir: string, fields: unknown[]) => ({
  name,
  label,
  folder: dir,
  extension: 'md', // only the .md files: `_category_.yaml` and images are left alone
  format: 'frontmatter',
  create: true,
  media_folder: 'img',
  public_folder: 'img',
  fields,
});

/** The editor's config.yml. [categories]: every docs folder, from the content repository. */
export function cmsConfig(categories: DocCategory[]): string {
  const docs = [...categories]
    .sort((a, b) => a.assetDir.localeCompare(b.assetDir))
    .map((c) => folder(`docs-${c.id.replace(/\//g, '-')}`, `Docs: ${c.label}`, c.assetDir, docFields));
  return stringify(
    {
      backend: {
        name: 'github',
        ...cmsRepo,
        commit_messages: {
          create: 'Add {{path}} (from the website editor)',
          update: 'Edit {{path}} (from the website editor)',
          delete: 'Delete {{path}} (from the website editor)',
          uploadMedia: 'Add {{path}} (from the website editor)',
          deleteMedia: 'Delete {{path}} (from the website editor)',
        },
      },
      // Fallback for uploads outside a collection; every collection has its own `img/`.
      media_folder: 'content/uploads',
      public_folder: '/uploads',
      output: { omit_empty_optional_fields: true },
      collections: [
        folder('docs', 'Docs: general (intro)', 'content/docs', docFields),
        ...docs,
        folder('pages', 'Pages', 'content/pages', [
          optional('title', 'Title (defaults to the first # heading)'),
          optional('description', 'Description', 'text'),
          optional('sidebar_position', 'Position', 'number', { value_type: 'int' }),
          body,
        ]),
      ],
    },
    { lineWidth: 0, aliasDuplicateObjects: false },
  );
}
