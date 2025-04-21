import 'package:ai_pt/src/workout_creation/workout_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';

class ActiveWorkoutSettings extends StatelessWidget {
  const ActiveWorkoutSettings({super.key});

  static const routeName = '/activeWorkoutSettings';

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Workout Settings'),
      ),
      body: Center(
        child: Text(
          "WIP",
          style: TextStyle(fontSize: 48), // Increased font size
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Save functionality (e.g., print responses)
                },
                child: const Text('Save'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete this workout plan?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  ) ?? false; // Handle null case
                  
                  if (confirmed && context.mounted) {
                    final currentWorkout = context.read<ActiveWorkoutProvider>().currentWorkout;
                    WorkoutManager().deleteWorkoutPlan(currentWorkout);
                    if (context.mounted) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
