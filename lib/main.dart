import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/app.dart';
import 'src/notifications/notification_manager.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env key‑value pairs (API keys, endpoints, …)
  await dotenv.load(fileName: '.env');

  // User‑configurable UI settings
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // Start the foreground/background notification service
  await NotificationManager.initializeService();

  runApp(MyApp(settingsController: settingsController));
}
