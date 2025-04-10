import 'package:ai_pt/src/dashboard/dashboard_details.dart';
import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'dashboard_item_class.dart';
import '../workout_overveiw/workout_overview.dart';

/// Displays a list of SampleItems.
class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
    this.items = const [SampleItem("Your Gains"), SampleItem("Your Weight"), SampleItem("Your Mobility")],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
            title: Text('Dashboard item: ${item.id}'),
            leading: const CircleAvatar(
              // Display the Flutter Logo image asset.
              foregroundImage: AssetImage('assets/images/flutter_logo.png'),
            ),
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                DashboardDetails.routeName,
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.restorablePushNamed(context, WorkoutOverview.routeName);
          },
          tooltip: 'Start Workout',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: FittedBox(
            child: const Text("Start Workout"),
          ),
        ),
      ),
    );
  }
}
