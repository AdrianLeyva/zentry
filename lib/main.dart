import 'package:flutter/material.dart';
import 'package:zentry/core/providers/environment_variables_provider.dart';
import 'package:zentry/core/providers/logger_provider.dart';
import 'package:zentry/core/theme/generic_theme.dart';
import 'package:zentry/features/feature_navigator/feature_navigator_screen.dart';
import 'package:zentry/modules/logger/logger.dart';

Future<void> main() async {
  await EnvironmentVariablesProvider.instance.init();
  LoggerProvider.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      themeMode: ThemeMode.system,
      home: const FeatureNavigatorScreen(),
    );
  }
}
