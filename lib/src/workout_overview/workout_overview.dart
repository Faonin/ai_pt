import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'package:ai_pt/src/workout_creation/workout_creation_view.dart';
import 'package:ai_pt/src/workout_overview/workout_adaptability_manager_view.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';
import 'package:ai_pt/src/workout_view/active_workout_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutOverview extends StatelessWidget {
  WorkoutOverview({super.key});

  static const routeName = '/workoutView';

  // Keep a single future so we don’t refetch unnecessarily.
  final Future<List<Map<String, String>>> _workoutsFuture = WorkoutStorageManager().fetchItems().then((items) => items
      .map((item) => {
            'name': item['name'] ?? 'Unnamed Workout',
            'type': item['workoutType'] ?? 'default',
          })
      .toList());

  IconData _iconForType(String type) {
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
        return Icons.fitness_center_outlined;
    }
  }

  void _onTap(BuildContext context, Map<String, String> workout) {
    final provider = context.read<ActiveWorkoutProvider>();
    final currentlyRunning = provider.currentWorkout;
    final willSwitch = currentlyRunning != 'No workout selected' && currentlyRunning != workout['name'];

    void start() {
      provider.setCurrentWorkout(workout['name']!);
      provider.setCurrentWorkoutType(workout['type']!);
      Navigator.restorablePushNamed(
        context,
        currentlyRunning == workout['name'] ? ActiveWorkoutView.routeName : WorkoutAdaptabilityManager.routeName,
      );
    }

    if (willSwitch) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Switch Workout?'),
          content: Text('Start "${workout['name']}" instead of the current workout?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  start();
                },
                child: const Text('Yes')),
          ],
        ),
      );
    } else {
      start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Your Workouts')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return const Center(child: Text('You haven\'t created any workouts yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: workouts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _onTap(context, workout),
                  child: ListTile(
                    leading: Icon(
                      _iconForType(workout['type']!),
                      size: 28,
                      color: scheme.onSurfaceVariant,
                    ),
                    title: Text(
                      workout['name']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.restorablePushNamed(context, WorkoutCreationView.routeName),
        tooltip: 'Create Workout',
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
