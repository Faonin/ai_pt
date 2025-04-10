import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class WorkoutView extends StatelessWidget {
  const WorkoutView({super.key});

  static const routeName = '/workoutView';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: const Center(
        child: Text('More Information Here'),
      ),
    );
  }
}
