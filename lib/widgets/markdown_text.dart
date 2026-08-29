// lib/widgets/markdown_text.dart
//
// Lightweight inline markdown renderer using only Flutter core — no packages.
// Handles the patterns Mistral commonly produces:
//   **bold**  *italic*  `code`  ### headings  --- dividers
//   - bullet lines   numbered lists   plain text
//
// Usage: MarkdownText(text: message.content, baseStyle: yourStyle)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final Color accentColor;

  const MarkdownText({
    super.key,
    required this.text,
    required this.baseStyle,
    this.accentColor = const Color(0xFF00E5FF),
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // ── Horizontal divider ──────────────────────────────────────────────
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        widgets.add(Divider(color: Colors.white12, height: 20));
        continue;
      }

      // ── Headings: ### ## # ──────────────────────────────────────────────
      if (trimmed.startsWith('### ')) {
        widgets.add(_buildRichLine(
          trimmed.substring(4),
          baseStyle.copyWith(
            fontSize: (baseStyle.fontSize ?? 13) + 1,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ));
        widgets.add(const SizedBox(height: 6));
        continue;
      }
      if (trimmed.startsWith('## ')) {
        widgets.add(_buildRichLine(
          trimmed.substring(3),
          baseStyle.copyWith(
            fontSize: (baseStyle.fontSize ?? 13) + 2,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
        widgets.add(const SizedBox(height: 6));
        continue;
      }
      if (trimmed.startsWith('# ')) {
        widgets.add(_buildRichLine(
          trimmed.substring(2),
          baseStyle.copyWith(
            fontSize: (baseStyle.fontSize ?? 13) + 3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // ── Bullet list: - item or * item ───────────────────────────────────
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        final content = trimmed.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ',
                  style: baseStyle.copyWith(color: accentColor, height: 1.5)),
              Expanded(child: _buildRichLine(content, baseStyle)),
            ],
          ),
        ));
        continue;
      }

      // ── Numbered list: 1. item ──────────────────────────────────────────
      final numberedMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(trimmed);
      if (numberedMatch != null) {
        final num = numberedMatch.group(1)!;
        final content = numberedMatch.group(2)!;
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$num. ',
                  style: baseStyle.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      height: 1.5)),
              Expanded(child: _buildRichLine(content, baseStyle)),
            ],
          ),
        ));
        continue;
      }

      // ── Empty line → small gap ──────────────────────────────────────────
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // ── Plain / inline-formatted line ───────────────────────────────────
      widgets.add(_buildRichLine(trimmed, baseStyle));
      if (i < lines.length - 1 && lines[i + 1].trim().isNotEmpty) {
        widgets.add(const SizedBox(height: 2));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Parses inline markers: **bold**, *italic*, `code`, and strips bare URLs
  Widget _buildRichLine(String text, TextStyle style) {
    return RichText(
      text: TextSpan(children: _parseInline(text, style)),
    );
  }

  List<InlineSpan> _parseInline(String text, TextStyle style) {
    final spans = <InlineSpan>[];
    // Regex order matters — longer/more-specific patterns first
    final pattern = RegExp(
      r'\*\*(.+?)\*\*'     // **bold**
      r'|\*(.+?)\*'        // *italic*
      r'|`(.+?)`'          // `code`
      r'|\[(.+?)\]\((.+?)\)' // [text](url) — rendered as accent-coloured text (no tappable link needed here)
      r'|(https?://\S+)',  // bare URL
    );

    int cursor = 0;
    for (final match in pattern.allMatches(text)) {
      // Text before this match
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, match.start),
          style: style,
        ));
      }

      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(1),
          style: style.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ));
      } else if (match.group(2) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(2),
          style: style.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        // `code`
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              match.group(3)!,
              style: GoogleFonts.robotoMono(
                fontSize: (style.fontSize ?? 13) - 1,
                color: accentColor,
              ),
            ),
          ),
        ));
      } else if (match.group(4) != null && match.group(5) != null) {
        // [text](url) — show the label text only, accent coloured
        spans.add(TextSpan(
          text: match.group(4),
          style: style.copyWith(
            color: accentColor,
            decoration: TextDecoration.underline,
            decorationColor: accentColor.withValues(alpha: 0.5),
          ),
        ));
      } else if (match.group(6) != null) {
        // bare URL — show shortened form
        final url = match.group(6)!;
        final display = url.length > 40 ? '${url.substring(0, 37)}…' : url;
        spans.add(TextSpan(
          text: display,
          style: style.copyWith(
            color: accentColor.withValues(alpha: 0.7),
            decoration: TextDecoration.underline,
            decorationColor: accentColor.withValues(alpha: 0.4),
          ),
        ));
      }

      cursor = match.end;
    }

    // Remaining text after last match
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: style));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: style)] : spans;
  }
}