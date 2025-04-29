import 'package:ai_pt/src/dashboard/dashboard_details.dart';
import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'dashboard_item_class.dart';
import '../workout_overview/workout_overview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Displays a list of SampleItems and includes a notification button.
class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
    this.items = const [
      SampleItem("Your Gains"),
      SampleItem("Your Weight"),
      SampleItem("Your Mobility"),
    ],
    required this.notificationsPlugin,
  });

  static const routeName = '/';

  final List<SampleItem> items;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  /// Helper to show a notification
  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'dashboard_channel',
      'Dashboard Notifications',
      channelDescription: 'Notifications from the dashboard',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_notification',
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      'Hello from Dashboard',
      'This is a test notification',
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(
                context,
                SettingsView.routeName,
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              restorationId: 'sampleItemListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return ListTile(
                  title: Text('Dashboard item: ${item.id}'),
                  leading: const CircleAvatar(),
                  onTap: () => Navigator.restorablePushNamed(
                    context,
                    DashboardDetails.routeName,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: _showNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('Send Notification'),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        child: FloatingActionButton(
          onPressed: () => Navigator.restorablePushNamed(context, WorkoutOverview.routeName),
          tooltip: 'Start Workout',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const FittedBox(
            child: Text("Start Workout"),
          ),
        ),
      ),
    );
  }
}
