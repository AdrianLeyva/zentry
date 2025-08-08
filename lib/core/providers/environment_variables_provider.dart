import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentVariablesProvider {
  static EnvironmentVariablesProvider? _instance;

  EnvironmentVariablesProvider._();

  static EnvironmentVariablesProvider get instance {
    _instance ??= EnvironmentVariablesProvider._();
    return _instance!;
  }

  Future<void> init() async {
    return await dotenv.load(fileName: "./dotenv");
  }

  static String _getEnv(String key, {String defaultValue = ""}) {
    return dotenv.env[key] ?? defaultValue;
  }

  String get geminiApiKey => _getEnv("GEMINI_API_KEY");
}
