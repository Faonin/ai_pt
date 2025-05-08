import 'package:ai_pt/src/workout_view/active_workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:ai_pt/src/workout_view/active_workout_view.dart';
import 'package:provider/provider.dart';

class WorkoutAdaptabilityManager extends StatefulWidget {
  const WorkoutAdaptabilityManager({super.key});

  static const routeName = '/workout_adaptability_manager';

  @override
  WorkoutAdaptabilityManagerState createState() =>
      WorkoutAdaptabilityManagerState();
}

class WorkoutAdaptabilityManagerState
    extends State<WorkoutAdaptabilityManager> {
  final TextEditingController _timeConstraintsController =
      TextEditingController();
  final TextEditingController _otherConsiderationsController =
      TextEditingController();
  int? _moodRating;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Workout Plan', textAlign: TextAlign.center),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              // Time Constraints text and field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Time Constraints',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeConstraintsController,
                decoration: const InputDecoration(
                  hintText: 'Do you have any time constraints today?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'How are you feeling?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final rating = index + 1;
                  final selected = _moodRating == rating;
                  return ElevatedButton(
                    onPressed: () => setState(() => _moodRating = rating),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selected ? cs.primary : cs.surfaceContainerHighest,
                      foregroundColor:
                          selected ? cs.onPrimary : cs.onSurfaceVariant,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      elevation: selected ? 4 : 0,
                    ),
                    child: Text('$rating'),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Other Considerations text and field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Other Considerations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otherConsiderationsController,
                decoration: const InputDecoration(
                  hintText: 'Like lack of equipment?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          cs.surfaceVariant, // flat pill-shaped background
                      foregroundColor: cs
                          .onSurface, // text color: black in light, white in dark
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ActiveWorkoutProvider>().setFlex([
                        'Time Constraints: ${_timeConstraintsController.text}',
                        'Mood Rating: $_moodRating',
                        'Other Considerations: ${_otherConsiderationsController.text}',
                      ]);

                      if (_moodRating == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Please fill in how your feeling.")),
                        );
                        return;
                      }
                      Navigator.pushReplacementNamed(
                          context, ActiveWorkoutView.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timeConstraintsController.dispose();
    _otherConsiderationsController.dispose();
    super.dispose();
  }
}
