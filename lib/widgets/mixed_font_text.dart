import 'package:flutter/material.dart';

/// Render text with **digits forced to TimesNewRoman**.
///
/// Flutter `TextStyle` can't apply a font per-character, so we split into spans.
class MixedFontText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const MixedFontText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  static final RegExp _digitRegex = RegExp(r'\d+');

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style.merge(style);
    final digitStyle = baseStyle.copyWith(fontFamily: 'TimesNewRoman');

    final spans = <InlineSpan>[];
    int index = 0;
    for (final match in _digitRegex.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start), style: baseStyle));
      }
      spans.add(TextSpan(text: match.group(0), style: digitStyle));
      index = match.end;
    }
    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index), style: baseStyle));
    }

    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      softWrap: softWrap ?? true,
      text: TextSpan(children: spans, style: baseStyle),
    );
  }
}

