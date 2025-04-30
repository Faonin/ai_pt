import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/app.dart';
import 'src/notifications/notification_manager.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

//final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// App entrypoint
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  await NotificationManager.initializeService();

  runApp(
    MyApp(
      settingsController: settingsController,
    ),
  );
}
