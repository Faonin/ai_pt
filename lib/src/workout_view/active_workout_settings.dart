import 'package:ai_pt/src/workout_creation/workout_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';

class ActiveWorkoutSettings extends StatefulWidget {
  ActiveWorkoutSettings({super.key});

  static const routeName = '/activeWorkoutSettings';

  final List<Map<String, dynamic>> questions = [
    {
      'type': 'free_text',
      'question': 'Change name of the workout:',
    },
    {
      'type': 'multiple',
      'question': 'Change workout preference:',
      'options': ['Indoor', 'Outdoor', 'Mix']
    },
    {
      'type': 'dropdown',
      'question': 'Change difficulty level:',
      'options': ['Easy', 'Medium', 'Hard']
    },
    {
      'type': 'dropdown',
      'question': 'How many days do you want to workout?',
      'options': ['1', '2', '3', '4', '5', '6', '7']
    },
    {
      'type': 'multi_select',
      'question': 'Select the days you want to workout:',
      'options': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    },
    {
      'type': 'multiple',
      'question': 'Choose warm-up duration:',
      'options': ['5 minutes', '10 minutes', '15 minutes', 'No warm-up']
    },
    {
      'type': 'free_text',
      'question': 'Enter any additional details:',
    },
  ];

  @override
  State<ActiveWorkoutSettings> createState() => _ActiveWorkoutSettingsState();
}

class _ActiveWorkoutSettingsState extends State<ActiveWorkoutSettings> {
  // Map to hold responses for each question.
  // For free_text, the value will be a String.
  // For multiple and dropdown, the value will be a String.
  // For multi_select, the value will be a Set<String>.
  final Map<int, dynamic> _responses = {};

  // Controllers for free_text fields (keyed by question index)
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout = context.watch<ActiveWorkoutProvider>().currentWorkout;
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings for $currentWorkout'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (question['type'] == 'free_text') ...[
                Text(
                  question['question'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _controllers.putIfAbsent(index, () => TextEditingController()),
                  decoration: const InputDecoration(
                    hintText: 'Enter your response',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _responses[index] = value;
                    });
                  },
                ),
              ] else if (question['type'] == 'multiple') ...[
                Text(
                  question['question'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8.0,
                  children: (question['options'] as List<String>).map((option) {
                    bool selected = _responses[index] == option;
                    return ChoiceChip(
                      label: Text(option),
                      selected: selected,
                      onSelected: (isSelected) {
                        setState(() {
                          // Toggle selection. Since it's a single selection,
                          // setting the same value deselects.
                          if (isSelected) {
                            _responses[index] = option;
                          } else {
                            _responses[index] = null;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ] else if (question['type'] == 'dropdown') ...[
                Text(
                  question['question'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _responses[index],
                  hint: const Text('Select an option'),
                  items: (question['options'] as List<String>).map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _responses[index] = value;
                    });
                  },
                ),
              ] else if (question['type'] == 'multi_select') ...[
                Text(
                  question['question'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8.0,
                  children: (question['options'] as List<String>).map((option) {
                    // Initialize a Set if needed.
                    _responses[index] ??= <String>{};
                    bool selected = (_responses[index] as Set<String>).contains(option);
                    return FilterChip(
                      label: Text(option),
                      selected: selected,
                      onSelected: (isSelected) {
                        setState(() {
                          final selections = _responses[index] as Set<String>;
                          if (isSelected) {
                            selections.add(option);
                          } else {
                            selections.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(),
            ],
          );
        },
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
                  print(_responses);
                },
                child: const Text('Save'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  bool? confirmed = await showDialog<bool>(
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
                  );
                  if (confirmed == true) {
                    // ignore: use_build_context_synchronously
                    final currentWorkout = context.read<ActiveWorkoutProvider>().currentWorkout;
                    await WorkoutManager().deleteWorkoutPlan(currentWorkout);
                    // ignore: use_build_context_synchronously
                    Navigator.popUntil(context, (route) => route.isFirst);
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
