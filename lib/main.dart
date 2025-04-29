import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

/// Global notifications plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// App entrypoint
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize settings controller
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // Run the app, passing settings and notification plugin
  runApp(
    MyApp(
      settingsController: settingsController,
      notificationsPlugin: flutterLocalNotificationsPlugin,
    ),
  );
}
