import 'package:ai_pt/src/ai_features/chat_messenger.dart';
import 'package:ai_pt/src/workout_view/active_workout_settings.dart';
import 'package:flutter/material.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class ActiveWorkoutView extends StatelessWidget {
  const ActiveWorkoutView({super.key});

  static const routeName = '/activeWorkoutView';

  void _handleSetCompletion(BuildContext context, Map<String, dynamic> exercise, int setIndex, Map<String, dynamic> userExercise) async {
    final setDetails = exercise["sets"][setIndex];
    final userSet = userExercise["sets"][setIndex];

    // Check if "amount" is filled and, if required, "dose" is filled.
    final isCompleted = userSet["amount"] != null && (setDetails["dose"] == "None" || userSet["dose"] != null);

    if (isCompleted) {
      // 25% chance to trigger
      final random = Random();
      if (random.nextDouble() < 0.1) {
        // Fetch encouragement message asynchronously and trigger the alert dialog
        final message = await CustomAssistantService().getEncouragementMessage(exercise["name"].toString());
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Set Completed!'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<ActiveWorkoutProvider>().currentWorkoutName),
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
        future: context.read<ActiveWorkoutProvider>().workoutDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!["exercises"].isEmpty) {
            return const Center(child: Text('No exercises available.'));
          }
          final exercises = snapshot.data!["exercises"];
          final currentUserExerciseInput = context.read<ActiveWorkoutProvider>().currentUserExerciseInput;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 160), // Prevent hiding behind the floating button
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final userExercise = currentUserExerciseInput["exercises"][index];

              return ExpansionTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(exercise["name"] ?? "No name"),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Exercise Info'),
                              content: Text(exercise["description"] ?? 'No description available.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                initiallyExpanded: index == 0, // Expand the first item by default
                children: [
                  for (var setIndex = 0; setIndex < exercise["sets"].length; setIndex++)
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Set ${exercise["sets"][setIndex]["set"]}:',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: TextEditingController(
                                text: userExercise["sets"][setIndex]["amount"]?.toString(),
                              ),
                              decoration: InputDecoration(
                                labelText: exercise["sets"][setIndex]["unit"].toString().replaceFirst(
                                      exercise["sets"][setIndex]["unit"][0],
                                      exercise["sets"][setIndex]["unit"][0].toUpperCase(),
                                    ),
                                hintText: exercise["sets"][setIndex]["amount"].toString(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                userExercise["sets"][setIndex]["amount"] = int.tryParse(value);
                                _handleSetCompletion(context, exercise, setIndex, userExercise);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (exercise["sets"][setIndex]["dose"] != "None")
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: TextEditingController(
                                  text: userExercise["sets"][setIndex]["dose"]?.toString(),
                                ),
                                decoration: InputDecoration(
                                  labelText: exercise["sets"][setIndex]["dose_unit"].toString(),
                                  hintText: exercise["sets"][setIndex]["dose"].toString(),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  userExercise["sets"][setIndex]["dose"] = int.tryParse(value);
                                  _handleSetCompletion(context, exercise, setIndex, userExercise);
                                },
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'RPE',
                              ),
                              value: userExercise["sets"][setIndex]["rpe"],
                              items: List.generate(
                                10,
                                (rpe) => DropdownMenuItem(
                                  value: rpe + 1,
                                  child: Text((rpe + 1).toString()),
                                ),
                              ),
                              onChanged: (value) {
                                userExercise["sets"][setIndex]["rpe"] = value;
                              },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        child: FloatingActionButton(
          onPressed: () {
            final currentUserExerciseInput = context.read<ActiveWorkoutProvider>().currentUserExerciseInput;
            bool incomplete = false;

            for (final exercise in currentUserExerciseInput["exercises"]) {
              for (final set in exercise["sets"]) {
                if (set["amount"] == null || (set.containsKey("dose") && set["dose"] == null)) {
                  incomplete = true;
                  break;
                }
              }
              if (incomplete) break;
            }
            if (incomplete) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Incomplete Workout'),
                  content: const Text('Some fields are still empty. Are you sure you want to finish the workout without completing all fields?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ActiveWorkoutProvider>().saveCurrentUserWorkout();
                        Navigator.of(context)
                          ..pop() // Close the dialog
                          ..pop(); // Close the workout view
                      },
                      child: const Text('Yes, finish workout'),
                    ),
                  ],
                ),
              );
              return;
            } else {
              context.read<ActiveWorkoutProvider>().saveCurrentUserWorkout();
              Navigator.pop(context);
            }
          },
          tooltip: 'Finish Workout',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: FittedBox(
            child: const Text(
              "Done",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
