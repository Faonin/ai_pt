import 'package:ai_pt/src/workout_view/active_workout_settings.dart';
import 'package:flutter/material.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';
import 'package:provider/provider.dart';

class ActiveAnaerobicWorkoutView extends StatelessWidget {
  const ActiveAnaerobicWorkoutView({super.key});

  static const routeName = '/activeAnaerobicWorkoutView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<ActiveWorkoutProvider>().currentWorkout),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, ActiveWorkoutSettings.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: context.read<ActiveWorkoutProvider>().workoutAnaerobicDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!["exercises"].isEmpty) {
            return const Center(child: Text('No exercises available.'));
          }
          final exercises = snapshot.data!["exercises"];
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ExpansionTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(exercise["name"]),
                ),
                initiallyExpanded: index == 0, // Expand the first item by default
                children: [
                  for (var set in exercise["sets"])
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Set ${set["set"]}:',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Reps',
                                hintText: set["reps"].toString(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Weight',
                                hintText: set["weight"].toString(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}