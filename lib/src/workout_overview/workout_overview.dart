import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'package:ai_pt/src/workout_creation/workout_creation_view.dart';
import 'package:ai_pt/src/workout_view/active_workout_view.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutOverview extends StatelessWidget {
  WorkoutOverview({super.key});

  static const routeName = '/workoutView';

  final workouts = WorkoutStorageManager().fetchItems().then((items) => items.map((item) {
        return {
          'name': item['name'] ?? 'Unnamed Workout',
          'type': item['workoutType'] ?? 'default',
        };
      }).toList());

  IconData _getIconForWorkoutType(String type) {
    switch (type) {
      case 'Cardio':
        return Icons.directions_run;
      case 'Strength':
        return Icons.sports_mma;
      case 'Flexibility':
        return Icons.self_improvement;
      case 'Muscle Growth':
        return Icons.fitness_center;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Workouts'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
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
                            GestureDetector(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getIconForWorkoutType(workout['type']!),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    workout['name']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              onTap: () {
                                String currentWorkout = context.read<ActiveWorkoutProvider>().currentWorkout;
                                if (currentWorkout != workout['name']! && currentWorkout != 'No workout selected') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Switch Workout'),
                                      content: const Text('Are you sure you want to switch workouts?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.read<ActiveWorkoutProvider>().setCurrentWorkout(workout['name']!);
                                            context.read<ActiveWorkoutProvider>().setCurrentWorkoutType(workout['type']!);
                                            Navigator.of(context).pop();
                                            Navigator.restorablePushNamed(context, ActiveWorkoutView.routeName);
                                          },
                                          child: const Text('Switch'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  context.read<ActiveWorkoutProvider>().setCurrentWorkout(workout['name']!);
                                  context.read<ActiveWorkoutProvider>().setCurrentWorkoutType(workout['type']!);
                                  Navigator.restorablePushNamed(context, ActiveWorkoutView.routeName);
                                }
                              },
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
