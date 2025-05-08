// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:ui'; // Needed for DartPluginRegistrant

import 'package:ai_pt/src/ai_features/chat_messenger.dart';
import 'package:ai_pt/src/storage_manager/training_logs_storage_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point') // Preserve the type for native lookup
class NotificationManager {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'workout_notifications_channel';
  static const _channelName = 'Workout Notifications';

  /// Called from main(); spins up a foreground service that outlives the UI.
  @pragma('vm:entry-point')
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onServiceStart,
        autoStart: true,
        isForegroundMode: true,
        // Mandatory on Android 13+ or the service is stopped:
        notificationChannelId: _channelId,
        initialNotificationTitle: 'AI-PT',
        initialNotificationContent: 'Background workout reminders active',
        foregroundServiceNotificationId: 1337,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: (_) async {},
        onBackground: (_) async => true,
      ),
    );

    await service.startService();
  }

  /// Entry-point for the secondary isolate created by flutter_background_service.
  @pragma('vm:entry-point')
  static Future<void> _onServiceStart(ServiceInstance service) async {
    // 1️⃣ Register every plugin you use in this isolate
    DartPluginRegistrant.ensureInitialized();

    // 2️⃣ Normal Flutter boot-strapping
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');

    // 3️⃣ Local-notifications plugin setup
    const androidInit = AndroidInitializationSettings('ic_notification');
    await _notifications.initialize(const InitializationSettings(android: androidInit));

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Scheduled workout notifications',
      importance: Importance.high,
    );
    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // 4️⃣ Periodic scheduler – runs every minute
    Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();
      print('Current time: ${now.hour}:${now.minute}'); // Debugging line);
      final isExactMinute = (now.hour == 8 || now.hour == 12 || now.hour == 18) && now.minute == 0;

      if (!isExactMinute) return;

      // Skip if the user already logged a workout today
      if ((await TrainingLogsStorageManager().fetchTodayItems()).isNotEmpty) return;

      final label = now.hour == 8
          ? 'Morning Boost'
          : now.hour == 12
              ? 'Midday Recharge'
              : 'Evening Relaxation';

      final msg = await CustomAssistantService().getNotificationMessage('${now.hour}:00');

      await _sendWorkoutNotification(label, msg);
    });
  }

  static Future<void> _sendWorkoutNotification(String title, String body) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Scheduled workout notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            '',
            contentTitle: title,
            summaryText: body,
          ),
        ),
      ),
    );
  }
}
