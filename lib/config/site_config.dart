import 'package:flutter/material.dart';
import '../widgets/common/brand_icons.dart';

/// Everything about *you* and the site's structure lives here.
///
/// Change a name, link or menu item in this file and the whole site updates.
/// Blog posts, docs and pages are Markdown files in `content/`, not here.
abstract final class SiteConfig {
  static const String siteName = 'Elmarath';
  static const String ownerName = 'Denizhan Toprak';
  static const String role = 'C++ Gameplay Programmer';
  static const String avatarUrl = 'https://avatars.githubusercontent.com/u/65414809?v=4';
  static const String logoAsset = 'assets/images/logo.png';

  // Home page hero.
  // A non-breaking space keeps "Unreal Engine" together when the line wraps on phones.
  static const String heroTitle = 'Gameplay systems,\nbuilt for Unreal\u00A0Engine.';
  static const String heroSubtitle =
      "I'm Denizhan, a C++ gameplay programmer. I build games and modular, production-ready "
      'plugins for Unreal Engine, and document every one of them here.';

  /// The showreel next to the hero text: short, muted clips that play one after
  /// another on a loop. Put them in `web/videos/`, each with a still of the same
  /// name ending in `.jpg`, shown until the clip can play.
  static const List<String> heroVideos = ['videos/skeletal-mesh-merge.mp4', 'videos/trace-trail.mp4'];

  /// Main navigation, left to right.
  static const List<NavItem> navItems = [
    NavItem(label: 'Home', path: '/'),
    NavItem(label: 'Docs', path: '/docs'),
    NavItem(label: 'Blog', path: '/blog'),
    NavItem(label: 'About', path: '/about'),
  ];

  /// The call-to-action button at the right of the nav bar.
  static const ExternalLink storeLink = ExternalLink(
    label: 'Fab Store',
    url: 'https://www.fab.com/sellers/Elmarath',
    icon: Icons.storefront_outlined,
  );

  static const String email = 'toprakdenizhan19@gmail.com';

  /// Your CV. Replace this PDF to update it everywhere.
  static const String cvAsset = 'assets/files/DenizhanToprak_Resume.pdf';

  /// Links to this path open the CV viewer window (and `/cv` shows it as a page).
  static const String resumeUrl = '/cv';

  /// Repository for "Edit this page" links on docs, e.g.
  /// 'https://github.com/Elmarath/ElmarathDev_Website/edit/main/'.
  /// Leave null to hide the link.
  static const String? editBaseUrl = null;

  /// Old addresses that moved somewhere else entirely, so links to them keep
  /// working. Letter case, spaces and dashes don't matter. Old docs and blog
  /// URLs from the Docusaurus site are matched automatically.
  static const Map<String, String> movedPages = {
    '/docs/PrivacyPolicy': '/privacy-policy',
    '/blog/About Me': '/about',
    '/blog/archive': '/blog',
    '/blog/authors': '/blog',
    '/blog/tags': '/blog',
    '/docs/Ability-Queue-Task-System/UseCaseExample copy': '/docs/ability-queue-task-system/use-case-example',
    // Docusaurus template pages.
    '/helloReact': '/',
    '/markdown-page': '/',
  };

  /// Social links: shown in the footer, the About page and the contact section.
  static const List<ExternalLink> socials = [
    ExternalLink(label: 'GitHub', url: 'https://github.com/Elmarath', icon: BrandIcons.github),
    ExternalLink(
      label: 'LinkedIn',
      url: 'https://www.linkedin.com/in/denizhan-toprak-006073193/',
      icon: BrandIcons.linkedin,
    ),
    ExternalLink(label: 'Discord', url: 'https://discord.gg/mUm4hYvG3x', icon: BrandIcons.discord),
    ExternalLink(
      label: 'YouTube',
      url: 'https://www.youtube.com/channel/UCVE1fkgWSSXIa-jZFVdDsaQ',
      icon: BrandIcons.youtube,
    ),
    ExternalLink(label: 'X', url: 'https://twitter.com/denizhan_toprak', icon: BrandIcons.xTwitter),
  ];

  /// Footer link columns.
  static const List<FooterColumn> footerColumns = [
    FooterColumn(
      title: 'Explore',
      links: [
        NavItem(label: 'Documentation', path: '/docs'),
        NavItem(label: 'Blog', path: '/blog'),
        NavItem(label: 'About me', path: '/about'),
      ],
    ),
    FooterColumn(
      title: 'Contact',
      links: [
        NavItem(label: 'Email', path: 'mailto:$email'),
        NavItem(label: 'Resume / CV', path: resumeUrl),
        NavItem(label: 'Fab Store', path: 'https://www.fab.com/sellers/Elmarath'),
      ],
    ),
    FooterColumn(title: 'Legal', links: [NavItem(label: 'Privacy Policy', path: '/privacy-policy')]),
  ];
}

/// An internal route (`/docs`) or an external URL (`https://…`, `mailto:…`).
class NavItem {
  const NavItem({required this.label, required this.path});

  final String label;
  final String path;
}

class ExternalLink {
  const ExternalLink({required this.label, required this.url, required this.icon});

  final String label;
  final String url;
  final IconData icon;
}

class FooterColumn {
  const FooterColumn({required this.title, required this.links});

  final String title;
  final List<NavItem> links;
}
