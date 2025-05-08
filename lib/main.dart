import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/app.dart';
import 'src/notifications/notification_manager.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load any key-value pairs you keep in .env
  await dotenv.load(fileName: '.env');

  // User-configurable settings (theme, locale, etc.)
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // Kick off the foreground/background notification service
  await NotificationManager.initializeService();

  runApp(MyApp(settingsController: settingsController));
}
