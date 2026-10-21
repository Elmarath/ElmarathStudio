import 'package:elmarath_dev_website/content/content_repository.dart';
import 'package:elmarath_dev_website/content/markdown_blocks.dart';
import 'package:elmarath_dev_website/content/text_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('slugify', () {
    test('handles Docusaurus-style names', () {
      expect(slugify('Easy-Trace-Trail-System'), 'easy-trace-trail-system');
      expect(slugify('AbilitySets.md'), 'ability-sets');
      expect(slugify('Decide%20Montages'), 'decide-montages');
      expect(slugify('02-setup'), 'setup');
      expect(slugify("Hermod's Ride"), 'hermods-ride');
    });
  });

  group('front matter', () {
    test('splits YAML from the body', () {
      final doc = FrontMatterDocument.parse('---\ntitle: Hello\ntags: [a, b]\n---\n\nBody');
      expect(doc.string('title'), 'Hello');
      expect(doc.list('tags'), ['a', 'b']);
      expect(doc.body.trim(), 'Body');
    });

    test('files without front matter keep their whole text', () {
      expect(FrontMatterDocument.parse('# Title').body, '# Title');
    });
  });

  group('markdown blocks', () {
    test('splits headings, admonitions and videos', () {
      final parsed = ParsedMarkdown.parse('''
Intro

## Setup

:::tip **Before you start**
    Indented content
:::

::youtube https://www.youtube.com/watch?v=abc123&t=90

```cpp
## not a heading
:::note
```

## Setup
''');
      final types = parsed.blocks.map((b) => b.runtimeType).toList();
      expect(types, [MdText, MdHeading, MdAdmonition, MdYoutube, MdText, MdHeading]);

      final admonition = parsed.blocks[2] as MdAdmonition;
      expect(admonition.type, 'tip');
      expect(admonition.title, 'Before you start');
      expect((admonition.children.single as MdText).markdown, 'Indented content');

      final video = parsed.blocks[3] as MdYoutube;
      expect(video.videoId, 'abc123');
      expect(video.start, 90);

      expect(parsed.headings.map((h) => h.id), ['setup', 'setup-1']);
    });

    test('understands GitHub alerts and iframes', () {
      final parsed = ParsedMarkdown.parse('''
> [!WARNING]
> Careful

<iframe width="100%" src="https://www.youtube.com/embed/xyz?start=12" frameborder="0"></iframe>
''');
      expect((parsed.blocks[0] as MdAdmonition).type, 'warning');
      expect((parsed.blocks[1] as MdYoutube).start, 12);
    });
  });

  group('repository', () {
    late ContentRepository content;

    setUpAll(() async {
      content = await ContentRepository.load(rootBundle);
    });

    test('loads docs, posts and pages', () {
      expect(content.plugins, isNotEmpty);
      expect(content.docPages, isNotEmpty);
      expect(content.posts, isNotEmpty);
      expect(content.pages.keys, contains('about'));
    });

    test('every doc and post has a title and route', () {
      for (final doc in content.docPages) {
        expect(doc.title, isNotEmpty, reason: doc.assetPath);
        expect(content.doc(doc.id), same(doc));
      }
      for (final post in content.posts) {
        expect(post.slug, isNotEmpty, reason: post.assetPath);
      }
    });

    test('resolves Docusaurus links and relative files', () {
      expect(
        content.internalRoute('/docs/Easy-Ability-Set-System/AbilitySets', sourcePath: 'content/docs/x.md'),
        '/docs/easy-ability-set-system/ability-sets',
      );
      expect(
        content.internalRoute('./Setup.md#sections', sourcePath: 'content/docs/Easy-Trace-Trail-System/FinalNotes.md'),
        '/docs/easy-trace-trail-system/setup#sections',
      );
      expect(content.internalRoute('https://example.com', sourcePath: 'content/docs/x.md'), isNull);
      expect(
        ContentRepository.resolveAsset('content/docs/A/B/page.md', '../img/x.png'),
        'content/docs/A/img/x.png',
      );
    });

    test('internal doc links point at real pages', () {
      final missing = <String>[];
      final link = RegExp(r'(?<!!)\[[^\]]*\]\(([^)\s]+)\)');
      final sources = [
        for (final d in content.docPages) (d.assetPath, d.body),
        for (final p in content.pages.values) (p.assetPath, p.body),
      ];
      for (final (assetPath, body) in sources) {
        for (final m in link.allMatches(body)) {
          final route = content.internalRoute(m.group(1)!, sourcePath: assetPath);
          if (route == null || !route.startsWith('/docs/')) continue;
          final id = route.substring('/docs/'.length).split('#').first;
          if (content.doc(id) == null && content.category(id) == null) missing.add('$assetPath → $route');
        }
      }
      expect(missing, isEmpty);
    });
  });
}
