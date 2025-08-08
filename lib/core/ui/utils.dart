import 'package:flutter/material.dart';

TextSpan parseRichText(String text, TextStyle defaultStyle) {
  final boldPattern = RegExp(r'\*\*(.+?)\*\*');
  final italicPattern = RegExp(r'\*(.+?)\*');

  List<InlineSpan> children = [];
  int currentIndex = 0;

  Iterable<RegExpMatch> allMatches = [
    ...boldPattern.allMatches(text),
    ...italicPattern.allMatches(text),
  ].toList()
    ..sort((a, b) => a.start.compareTo(b.start));

  for (final match in allMatches) {
    if (match.start > currentIndex) {
      children.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: defaultStyle));
    }
    final matchedText = match.group(1)!;
    if (match.pattern == boldPattern) {
      children.add(TextSpan(
          text: matchedText,
          style: defaultStyle
              .merge(const TextStyle(fontWeight: FontWeight.bold))));
    } else if (match.pattern == italicPattern) {
      children.add(TextSpan(
          text: matchedText,
          style: defaultStyle
              .merge(const TextStyle(fontStyle: FontStyle.italic))));
    }
    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    children
        .add(TextSpan(text: text.substring(currentIndex), style: defaultStyle));
  }

  return TextSpan(children: children, style: defaultStyle);
}
