import 'dart:async';
import 'package:ai_pt/src/ai_features/chat_messenger.dart';
import 'package:ai_pt/src/storage_manager/training_logs_storage_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'workout_notifications_channel';
  static const _channelName = 'Workout Notifications';

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onServiceStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: (_) async {},
        onBackground: (_) async => true,
      ),
    );
    service.startService();
  }

  @pragma('vm:entry-point')
  static Future<void> _onServiceStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    const androidInit = AndroidInitializationSettings('ic_notification');
    await _notifications.initialize(
      const InitializationSettings(android: androidInit),
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Scheduled workout notifications',
      importance: Importance.high,
    );

    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    Timer.periodic(
      const Duration(minutes: 1),
      (_) async {
        final now = DateTime.now();
        if (now.hour == 8 && now.minute == 0) {
          if ((await TrainingLogsStorageManager().fetchTodayItems()).isEmpty) {
            await _sendWorkoutNotification('Morning Boost', await CustomAssistantService().getNotificationMessage('8:00'));
          }
        }

        if (now.hour == 12 && now.minute == 0) {
          if ((await TrainingLogsStorageManager().fetchTodayItems()).isEmpty) {
            await _sendWorkoutNotification('Midday Recharge', await CustomAssistantService().getNotificationMessage('12:00'));
          }
        }

        if (now.hour == 18 && now.minute == 0) {
          if ((await TrainingLogsStorageManager().fetchTodayItems()).isEmpty) {
            await _sendWorkoutNotification('Evening Relaxation', await CustomAssistantService().getNotificationMessage('18:00'));
          }
        }
      },
    );
  }

  static Future<void> _sendWorkoutNotification(String title, String message) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      message,
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
            message,
            contentTitle: title,
          ),
        ),
      ),
    );
  }
}
