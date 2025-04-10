import 'package:ai_pt/src/workout_creation/workout_creation_view.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class WorkoutOverview extends StatelessWidget {
  WorkoutOverview({super.key});

  static const routeName = '/workoutView';

  final workouts = [
    'Workout 1',
    'Workout 2',
    'Workout 3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Workouts'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var workout in workouts) ...[
                Text(workout),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.restorablePushNamed(context, WorkoutCreationView.routeName);
        },
        tooltip: 'Create Workout',
        child: const Icon(Icons.add),
      ),
    );
  }
}
