// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import { themes as prismThemes } from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Elmarath Studio',
  tagline: 'Game and Game Tools Development',
  favicon: 'img/favicon.ico',


  // Set the production url of your site here
  url: 'https://elmarath.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'Elmarath', // Usually your GitHub org/user name.
  projectName: 'ElmarathStudio', // Usually your repo name.
  deploymentBranch: 'master',
  trailingSlash: false,
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid'],

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          // editUrl removed to disable "Edit this page" links
        },
        blog: {
          showReadingTime: true,
          // editUrl removed to disable "Edit this page" links
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/T_ElmarathLogo.png',
      navbar: {
        title: 'Elmarath Studio',
        logo: {
          alt: 'Elmarath Logo',
          src: 'img/T_ElmarathLogo.png',
        },
        hideOnScroll: true,
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Plug-in Tutorials',
          },
          { to: '/blog', label: 'About Me', position: 'right' },
          {
            href: 'https://github.com/Elmarath',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Plug-in Tutorials',
                to: '/docs/intro',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Youtube',
                href: 'https://www.youtube.com/channel/UCVE1fkgWSSXIa-jZFVdDsaQ',
              },
              {
                label: 'Discord',
                href: 'https://discord.gg/HghXuWHJJx',
              },
              {
                label: 'Twitter',
                href: 'https://twitter.com/denizhan_toprak',
              },
            ],
          },
          {
            title: 'Contact',
            items: [
              {
                label: 'Email',
                href: 'mailto:toprakdenizhan19@gmail.com',
              },
              {
                label: 'LinkedIn',
                href: 'https://www.linkedin.com/in/denizhan-toprak-game-developer/',
              },
              {
                label: 'Resume/CV',
                href: 'https://drive.google.com/file/d/1lQJwU5A7gPQBOh1OjnKqxQo6ug71s7tL/view?usp=sharing',
              },
              {
                label: 'GitHub Profile',
                href: 'https://github.com/Elmarath',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Blog',
                to: '/blog',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/facebook/docusaurus',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Elmarath Studio, Inc.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
      colorMode: {
        defaultMode: 'dark'
      },
    }),
  plugins: [
    [
      '@docusaurus/plugin-google-gtag',
      {
        trackingID: 'G-CRZ373MY93',
        anonymizeIP: true,
      },
    ],
  ],
};

export default config;