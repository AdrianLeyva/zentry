import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zentry/core/ui/utils.dart';

class GenericTextDialog extends StatelessWidget {
  final String title;
  final String mainText;
  final Map<String, dynamic>? jsonData;
  final String closeButtonText;
  final VoidCallback? onClose;

  const GenericTextDialog(
      {super.key,
      required this.title,
      required this.mainText,
      this.jsonData,
      this.closeButtonText = 'Close',
      this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText.rich(
              parseRichText(mainText, TextStyle(color: Colors.black87)),
            ),
            if (jsonData != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Additional Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText.rich(
                parseRichText(JsonEncoder.withIndent('  ').convert(jsonData),
                    TextStyle(color: Colors.black87)),
              ),
              Text(
                const JsonEncoder.withIndent('  ').convert(jsonData),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          child: Text(closeButtonText),
        ),
      ],
    );
  }
}
