// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:ui'; // Needed for DartPluginRegistrant

import 'package:ai_pt/src/ai_features/chat_messenger.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point') // keep class for reflection
class NotificationManager {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'workout_notifications_channel';
  static const _channelName = 'Workout Notifications';

  /// Called from main(); registers the channel **before** the service starts.
  @pragma('vm:entry-point')
  static Future<void> initializeService() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1️⃣  Local‑notifications initialization in the UI isolate
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
    );
    await _notifications.initialize(initSettings);

    // 2️⃣  Register the notification‑channel (needed for startForeground)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Scheduled workout notifications',
      importance: Importance.low, // low is enough for foreground service
    );
    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // 3️⃣  Start the background service only if it isn’t running
    final service = FlutterBackgroundService();
    if (await service.isRunning()) return;

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onServiceStart,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'AI‑PT',
        initialNotificationContent: 'Workout reminders active',
        foregroundServiceNotificationId: 1337,
      ),
      iosConfiguration: IosConfiguration(),
    );

    await service.startService();
  }

  /// Entry‑point for the secondary isolate spawned by flutter_background_service.
  @pragma('vm:entry-point')
  static Future<void> _onServiceStart(ServiceInstance service) async {
    // 1️⃣  Register plugins and load env in the new isolate
    DartPluginRegistrant.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');

    // 2️⃣  Re‑register the channel (safe if it already exists)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Scheduled workout notifications',
      importance: Importance.unspecified,
    );
    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // 3️⃣  Bring the service to foreground if not yet
    if (service is AndroidServiceInstance && !(await service.isForegroundService())) {
      await service.setForegroundNotificationInfo(
        title: 'AI‑PT running',
        content: 'Tap to open the app',
      );
    }

    // 4️⃣  Periodic task – every full hour at 08, 12 and 18 o’clock
    Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();
      const interestingHours = {8, 12, 18};
      if (!interestingHours.contains(now.hour) || now.minute != 0) return;

      final label = switch (now.hour) {
        8 => 'Morning Boost',
        12 => 'Midday Recharge',
        _ => 'Evening Relaxation',
      };

      final msg = await CustomAssistantService().getNotificationMessage('${now.hour}:00');

      await _sendWorkoutNotification(label, msg);
    });
  }

  static Future<void> _sendWorkoutNotification(String title, String body) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Scheduled workout notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(body),
          icon: 'ic_notification',
        ),
      ),
    );
  }
}
