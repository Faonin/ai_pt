import 'package:flutter/material.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutView extends StatelessWidget {
  const ActiveWorkoutView({super.key});

  static const routeName = '/activeWorkoutView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<ActiveWorkoutProvider>().currentWorkout),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Change settings about the workout
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: context.read<ActiveWorkoutProvider>().workoutDetails["exercises"].length,
        itemBuilder: (context, index) {
          final exercise = context.watch<ActiveWorkoutProvider>().workoutDetails["exercises"][index];
          return ListTile(
            title: Text(exercise["name"]),
            subtitle: Text('Reps: ${exercise["reps"]}, Sets: ${exercise["sets"]}'),
          );
        },
      ),
    );
  }
}
