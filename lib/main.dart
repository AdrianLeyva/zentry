import 'package:flutter/material.dart';
import 'package:zentry/core/providers/environment_variables_provider.dart';
import 'package:zentry/core/theme/generic_theme.dart';
import 'package:zentry/features/feature_navigator/feature_navigator_screen.dart';

Future<void> main() async {
  await EnvironmentVariablesProvider.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const FeatureNavigatorScreen(),
    );
  }
}
