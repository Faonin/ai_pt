import 'dart:math';

import 'package:ai_pt/src/ai_features/chat_messenger.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';
import 'package:ai_pt/src/workout_view/active_workout_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Active workout screen – now uses a `StatefulBuilder` around each RPE picker
/// so the dropdown updates immediately without converting the whole view to a
/// `StatefulWidget`.
class ActiveWorkoutView extends StatelessWidget {
  const ActiveWorkoutView({super.key});

  static const routeName = '/activeWorkoutView';

  //--------------------------------------------------------------------------
  // Chat overlay
  //--------------------------------------------------------------------------
  void _showChatDialog(BuildContext context) {
    context.read<ActiveWorkoutProvider>().clearChatResponse();
    const options = ['Motivation', 'Question', 'Talk'];
    String message = '';
    int selectedIndex = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final response = context.watch<ActiveWorkoutProvider>().chatResponse;
          return AlertDialog(
            title: const Text('Chat with AI Assistant'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Chat bubble
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        response.isEmpty ? '...' : response,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                  // Quick-select chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(options.length, (i) {
                      final isSelected = i == selectedIndex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            options[i],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      label: Center(child: Text('Type your message here')),
                    ),
                    onChanged: (v) => message = v,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  if (message.isNotEmpty) {
                    final chosen = options[selectedIndex];
                    context.read<ActiveWorkoutProvider>().getChatResponse(message, chosen);
                  }
                },
                child: const Text('Send'),
              ),
            ],
          );
        },
      ),
    );
  }

  //--------------------------------------------------------------------------
  // Detect when a set is finished and maybe show an encouragement dialog
  //--------------------------------------------------------------------------
  Future<void> _handleSetCompletion(BuildContext context, Map<String, dynamic> exercise, int setIndex, Map<String, dynamic> userEx) async {
    final setDef = exercise['sets'][setIndex];
    final userSet = userEx['sets'][setIndex];
    final completed = userSet['amount'] != null && (setDef['dose'] == 'None' || userSet['dose'] != null);

    if (completed && Random().nextDouble() < 0.05) {
      final msg = await CustomAssistantService().getEncouragementMessage(exercise['name']);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Set Completed!'),
            content: Text(msg),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
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
          IconButton(icon: const Icon(Icons.chat_bubble), onPressed: () => _showChatDialog(context)),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.restorablePushNamed(context, ActiveWorkoutSettings.routeName),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: context.read<ActiveWorkoutProvider>().workoutDetails,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData || snap.data!['exercises'].isEmpty) {
            return const Center(child: Text('No exercises available.'));
          }

          final exercises = snap.data!['exercises'];
          final userInput = context.read<ActiveWorkoutProvider>().currentUserExerciseInput;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 160),
            itemCount: exercises.length,
            itemBuilder: (context, exIdx) {
              final exercise = exercises[exIdx];
              final userExercise = userInput['exercises'][exIdx];

              return ExpansionTile(
                initiallyExpanded: exIdx == 0,
                title: Row(
                  children: [
                    Expanded(child: Text(exercise['name'] ?? 'No name')),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Exercise Info'),
                          content: Text(exercise['description'] ?? 'No description available.'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  for (var setIdx = 0; setIdx < exercise['sets'].length; ++setIdx)
                    Padding(
                      padding: const EdgeInsets.only(left: 32, top: 8, bottom: 8),
                      child: Row(
                        children: [
                          //------------------------------------------------------------------ label
                          Expanded(
                            flex: 2,
                            child: Text('Set ${exercise['sets'][setIdx]['set']}:', style: const TextStyle(fontSize: 16)),
                          ),
                          //------------------------------------------------------------------ amount
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: userExercise['sets'][setIdx]['amount']?.toString(),
                              decoration: InputDecoration(
                                labelText: exercise['sets'][setIdx]['unit'].toString().replaceFirst(
                                      exercise['sets'][setIdx]['unit'][0],
                                      exercise['sets'][setIdx]['unit'][0].toUpperCase(),
                                    ),
                                hintText: exercise['sets'][setIdx]['amount'].toString(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                userExercise['sets'][setIdx]['amount'] = int.tryParse(v);
                                _handleSetCompletion(context, exercise, setIdx, userExercise);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          //------------------------------------------------------------------ dose (optional)
                          if (exercise['sets'][setIdx]['dose'] != 'None')
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: userExercise['sets'][setIdx]['dose']?.toString(),
                                decoration: InputDecoration(
                                  labelText: exercise['sets'][setIdx]['dose_unit'].toString(),
                                  hintText: exercise['sets'][setIdx]['dose'].toString(),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  userExercise['sets'][setIdx]['dose'] = v;
                                  _handleSetCompletion(context, exercise, setIdx, userExercise);
                                },
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: StatefulBuilder(
                              builder: (context, dropSetState) => DropdownButtonFormField<int?>(
                                decoration: const InputDecoration(labelText: 'RPE'),
                                value: userExercise['sets'][setIdx]['rpe'],
                                items: [
                                  DropdownMenuItem(value: null, child: Text('-')),
                                  ...[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                                ],
                                onChanged: (val) {
                                  dropSetState(() => userExercise['sets'][setIdx]['rpe'] = val);
                                },
                              ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tooltip: 'Finish Workout',
          child: const FittedBox(child: Text('Done', style: TextStyle(fontSize: 18))),
          onPressed: () {
            final input = context.read<ActiveWorkoutProvider>().currentUserExerciseInput;
            final incomplete = (input['exercises'] as List)
                .any((ex) => (ex['sets'] as List).any((set) => (set['amount'] == null || (set.containsKey('dose') && set['dose'] == null))));

            if (incomplete) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Incomplete Workout'),
                  content: const Text('Some fields are still empty. Finish anyway?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        context.read<ActiveWorkoutProvider>().saveCurrentUserWorkout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', // route name of your front page
                            (Route<dynamic> _) => false,
                          );
                        }
                      },
                      child: const Text('Yes, finish'),
                    ),
                  ],
                ),
              );
            } else {
              context.read<ActiveWorkoutProvider>().saveCurrentUserWorkout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', // route name of your front page
                  (Route<dynamic> _) => false,
                );
              }
            }
          },
        ),
      ),
    );
  }
}
