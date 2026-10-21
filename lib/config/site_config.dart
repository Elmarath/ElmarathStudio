import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  static const String heroEyebrow = 'Unreal Engine · C++ · Gameplay tools';
  static const String heroTitle = 'Gameplay systems,\nbuilt for Unreal Engine.';
  static const String heroSubtitle =
      "I'm Denizhan, a C++ gameplay programmer. I build modular, production-ready "
      'plugins for Unreal Engine, and document every one of them here.';
  static const String heroImage = 'assets/images/hero.jpeg';

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
  static const String resumeUrl =
      'https://docs.google.com/document/d/1NyO2H-jLeTuhU76wPoMm6xU3kDFCQn3Dn-A5imPmtfA/edit?tab=t.0';

  /// Repository for "Edit this page" links on docs, e.g.
  /// 'https://github.com/Elmarath/ElmarathDev_Website/edit/main/'.
  /// Leave null to hide the link.
  static const String? editBaseUrl = null;

  /// Social links: shown in the footer, the About page and the contact section.
  static const List<ExternalLink> socials = [
    ExternalLink(label: 'GitHub', url: 'https://github.com/Elmarath', icon: FontAwesomeIcons.github),
    ExternalLink(
      label: 'LinkedIn',
      url: 'https://www.linkedin.com/in/denizhan-toprak-006073193/',
      icon: FontAwesomeIcons.linkedin,
    ),
    ExternalLink(label: 'Discord', url: 'https://discord.gg/mUm4hYvG3x', icon: FontAwesomeIcons.discord),
    ExternalLink(
      label: 'YouTube',
      url: 'https://www.youtube.com/channel/UCVE1fkgWSSXIa-jZFVdDsaQ',
      icon: FontAwesomeIcons.youtube,
    ),
    ExternalLink(label: 'X', url: 'https://twitter.com/denizhan_toprak', icon: FontAwesomeIcons.xTwitter),
  ];

  /// "What you'll find here" cards on the home page.
  static const List<SiteFeature> features = [
    SiteFeature(
      icon: Icons.menu_book_outlined,
      title: 'Plugin documentation',
      description: 'Step-by-step guides for every plugin: setup, examples and the reasoning behind the design.',
      link: '/docs',
      linkLabel: 'Browse the docs',
    ),
    SiteFeature(
      icon: Icons.edit_note_outlined,
      title: 'Dev blog',
      description: "Devlogs from Hermod's Ride, deep dives into Unreal systems and lessons from shipping tools.",
      link: '/blog',
      linkLabel: 'Read the blog',
    ),
    SiteFeature(
      icon: Icons.person_outline,
      title: 'About me',
      description: 'Who I am, what I work on, and what kind of roles and collaborations I am open to.',
      link: '/about',
      linkLabel: 'Get to know me',
    ),
    SiteFeature(
      icon: Icons.forum_outlined,
      title: 'Community',
      description: 'Questions about a plugin? Join the Discord, where bugs get fixed and features get requested.',
      link: 'https://discord.gg/mUm4hYvG3x',
      linkLabel: 'Join the Discord',
    ),
  ];

  /// Footer link columns.
  static const List<FooterColumn> footerColumns = [
    FooterColumn(title: 'Explore', links: [
      NavItem(label: 'Documentation', path: '/docs'),
      NavItem(label: 'Blog', path: '/blog'),
      NavItem(label: 'About me', path: '/about'),
    ]),
    FooterColumn(title: 'Contact', links: [
      NavItem(label: 'Email', path: 'mailto:$email'),
      NavItem(label: 'Resume / CV', path: resumeUrl),
      NavItem(label: 'Fab Store', path: 'https://www.fab.com/sellers/Elmarath'),
    ]),
    FooterColumn(title: 'Legal', links: [
      NavItem(label: 'Privacy Policy', path: '/privacy-policy'),
    ]),
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

class SiteFeature {
  const SiteFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.link,
    required this.linkLabel,
  });

  final IconData icon;
  final String title;
  final String description;
  final String link;
  final String linkLabel;
}

class FooterColumn {
  const FooterColumn({required this.title, required this.links});

  final String title;
  final List<NavItem> links;
}
