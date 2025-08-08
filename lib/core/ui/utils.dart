import 'package:flutter/material.dart';

TextSpan parseRichText(String text, TextStyle defaultStyle) {
  List<InlineSpan> spans = [];
  int index = 0;

  final pattern = RegExp(r'(\*\*|[*])(.+?)\1');
  final matches = pattern.allMatches(text);

  for (final match in matches) {
    if (match.start > index) {
      spans.add(TextSpan(
        text: text.substring(index, match.start),
        style: defaultStyle,
      ));
    }

    final marker = match.group(1);
    final content = match.group(2)!;

    if (marker == '**') {
      spans.add(TextSpan(
        text: content,
        style: defaultStyle.merge(const TextStyle(fontWeight: FontWeight.bold)),
      ));
    } else if (marker == '*') {
      spans.add(TextSpan(
        text: content,
        style: defaultStyle.merge(const TextStyle(fontStyle: FontStyle.italic)),
      ));
    }

    index = match.end;
  }

  if (index < text.length) {
    spans.add(TextSpan(
      text: text.substring(index),
      style: defaultStyle,
    ));
  }

  return TextSpan(children: spans, style: defaultStyle);
}
