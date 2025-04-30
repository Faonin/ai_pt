import 'package:ai_pt/src/dashboard/dashboard_details.dart';
import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'dashboard_item_class.dart';
import '../workout_overview/workout_overview.dart';

/// Displays a list of SampleItems and includes a notification button.
class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
    this.items = const [
      SampleItem("Your Gains"),
      SampleItem("Your Weight"),
      SampleItem("Your Mobility"),
    ],
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
