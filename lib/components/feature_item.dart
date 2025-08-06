import 'package:flutter/cupertino.dart';

class FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final Widget Function() screenBuilder;

  FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.screenBuilder,
  });
}
