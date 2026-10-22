import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:highlight/highlight_core.dart' show Highlight, Node;
import 'package:highlight/languages/bash.dart' as bash_lang;
import 'package:highlight/languages/cmake.dart' as cmake_lang;
import 'package:highlight/languages/cpp.dart' as cpp_lang;
import 'package:highlight/languages/cs.dart' as cs_lang;
import 'package:highlight/languages/css.dart' as css_lang;
import 'package:highlight/languages/dart.dart' as dart_lang;
import 'package:highlight/languages/diff.dart' as diff_lang;
import 'package:highlight/languages/glsl.dart' as glsl_lang;
import 'package:highlight/languages/ini.dart' as ini_lang;
import 'package:highlight/languages/javascript.dart' as javascript_lang;
import 'package:highlight/languages/json.dart' as json_lang;
import 'package:highlight/languages/lua.dart' as lua_lang;
import 'package:highlight/languages/markdown.dart' as markdown_lang;
import 'package:highlight/languages/plaintext.dart' as plaintext_lang;
import 'package:highlight/languages/powershell.dart' as powershell_lang;
import 'package:highlight/languages/python.dart' as python_lang;
import 'package:highlight/languages/shell.dart' as shell_lang;
import 'package:highlight/languages/sql.dart' as sql_lang;
import 'package:highlight/languages/typescript.dart' as typescript_lang;
import 'package:highlight/languages/xml.dart' as xml_lang;
import 'package:highlight/languages/yaml.dart' as yaml_lang;
import 'package:markdown/markdown.dart' as md;

import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Replaces Markdown's fenced code blocks with [CodeBlock].
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    String? language;
    final code = element.children?.firstOrNull;
    if (code is md.Element) {
      language = code.attributes['class']?.replaceFirst('language-', '');
    }
    return CodeBlock(code: element.textContent.replaceFirst(RegExp(r'\n$'), ''), language: language);
  }
}

/// The languages code blocks are coloured for. Only these are built into the
/// site (the highlighter knows 190, which made the site's script much bigger);
/// a block in any other language shows as plain text. Add one here to colour it.
final _highlighter =
    Highlight()..registerLanguages({
      'bash': bash_lang.bash,
      'cmake': cmake_lang.cmake,
      'cpp': cpp_lang.cpp,
      'cs': cs_lang.cs,
      'css': css_lang.css,
      'dart': dart_lang.dart,
      'diff': diff_lang.diff,
      'glsl': glsl_lang.glsl,
      'ini': ini_lang.ini,
      'javascript': javascript_lang.javascript,
      'json': json_lang.json,
      'lua': lua_lang.lua,
      'markdown': markdown_lang.markdown,
      'plaintext': plaintext_lang.plaintext,
      'powershell': powershell_lang.powershell,
      'python': python_lang.python,
      'shell': shell_lang.shell,
      'sql': sql_lang.sql,
      'typescript': typescript_lang.typescript,
      'xml': xml_lang.xml,
      'yaml': yaml_lang.yaml,
    });

/// Short names people type after ``` mapped to highlight.js language ids.
const _aliases = {
  'c++': 'cpp',
  'h': 'cpp',
  'hpp': 'cpp',
  'ue': 'cpp',
  'unreal': 'cpp',
  'uplugin': 'json',
  'uproject': 'json',
  'cs': 'csharp',
  'js': 'javascript',
  'ts': 'typescript',
  'sh': 'bash',
  'shell': 'bash',
  'zsh': 'bash',
  'yml': 'yaml',
  'py': 'python',
  'ini': 'ini',
  'txt': 'plaintext',
  'text': 'plaintext',
};

/// A syntax-highlighted code block with a language label and copy button.
class CodeBlock extends StatefulWidget {
  const CodeBlock({super.key, required this.code, this.language});

  final String code;
  final String? language;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;
  final _scroll = ScrollController();

  String? get _language {
    final raw = widget.language?.trim().toLowerCase().replaceFirst(RegExp(r'^\.'), '');
    if (raw == null || raw.isEmpty) return null;
    return _aliases[raw] ?? raw;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  List<TextSpan> _highlight(Map<String, TextStyle> theme) {
    final language = _language;
    if (language == null || language == 'plaintext' || language == 'mermaid') {
      return [TextSpan(text: widget.code)];
    }
    try {
      final nodes = _highlighter.parse(widget.code, language: language).nodes ?? const [];
      return _toSpans(nodes, theme);
    } catch (_) {
      return [TextSpan(text: widget.code)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final label = (widget.language?.replaceFirst(RegExp(r'^\.'), '') ?? 'code').toUpperCase();
    final baseColor = p.codeTheme['root']?.color ?? p.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: p.codeBackground,
        borderRadius: Radii.mdAll,
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, right: 6),
            height: 38,
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
            child: Row(
              children: [
                Text(label, style: text.labelSmall),
                const Spacer(),
                IconButton(
                  tooltip: _copied ? 'Copied' : 'Copy',
                  iconSize: 16,
                  visualDensity: VisualDensity.compact,
                  onPressed: _copy,
                  icon: AnimatedSwitcher(
                    duration: Motion.fast,
                    child: Icon(
                      _copied ? Icons.check : Icons.content_copy_outlined,
                      key: ValueKey(_copied),
                      color: _copied ? p.tip : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Scrollbar(
            controller: _scroll,
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Text.rich(
                TextSpan(
                  style: AppTheme.code(color: baseColor),
                  children: _highlight(p.codeTheme),
                ),
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<TextSpan> _toSpans(List<Node> nodes, Map<String, TextStyle> theme) {
  TextSpan convert(Node node) {
    final style = node.className == null ? null : theme[node.className!];
    if (node.value != null) return TextSpan(text: node.value, style: style);
    return TextSpan(style: style, children: node.children?.map(convert).toList());
  }

  return nodes.map(convert).toList();
}
