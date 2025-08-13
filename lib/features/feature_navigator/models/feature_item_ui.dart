import 'package:flutter/cupertino.dart';

class FeatureItemUi {
  final String title;
  final String description;
  final IconData icon;
  final Widget Function() screenBuilder;

  FeatureItemUi({
    required this.title,
    required this.description,
    required this.icon,
    required this.screenBuilder,
  });
}
