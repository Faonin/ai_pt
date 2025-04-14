import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'package:ai_pt/src/workout_creation/workout_creation_view.dart';
import 'package:flutter/material.dart';

class WorkoutOverview extends StatelessWidget {
  WorkoutOverview({super.key});

  static const routeName = '/workoutView';

  final workouts = WorkoutStorageManager().fetchItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Workouts'),
      ),
      body: FutureBuilder<List<String>>(
        future: workouts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workouts found.'));
          } else {
            final items = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var workout in items) ...[
                            Text(
                              workout,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
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
