import 'package:flutter/material.dart';

class GenericCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  const GenericCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final goldColor = color ?? const Color(0xFFCBA135);

    return Card(
      color: goldColor.withValues(alpha: 0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: goldColor.withValues(alpha: 0.9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: goldColor.withValues(alpha: 0.8),
        highlightColor: goldColor.withValues(alpha: 0.4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle(
            style: TextStyle(color: goldColor),
            child: child,
          ),
        ),
      ),
    );
  }
}
