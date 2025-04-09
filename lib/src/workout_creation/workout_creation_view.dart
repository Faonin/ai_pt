import 'package:flutter/material.dart';

class WorkoutCreationView extends StatefulWidget {
  const WorkoutCreationView({super.key});

  static const routeName = '/workout_creation';

  @override
  WorkoutCreationViewState createState() => WorkoutCreationViewState();
}

class WorkoutCreationViewState extends State<WorkoutCreationView> {
  final List<Map<String, dynamic>> _questions = [
    {
      'type': 'multiple',
      'question': 'Select your workout type:',
      'options': ['Cardio', 'Strength', 'Flexibility']
    },
    {
      'type': 'multiple',
      'question': 'Select your workout preference:',
      'options': ['Indoor', 'Outdoor', 'Mix']
    },
    {
      'type': 'dropdown',
      'question': 'Select difficulty level:',
      'options': ['Easy', 'Medium', 'Hard']
    },
    {
      'type': 'multiple',
      'question': 'Choose warm-up duration:',
      'options': ['5 minutes', '10 minutes', '15 minutes', 'No warm-up']
    },
  ];

  int _currentQuestionIndex = 0;
  String? _dropdownValue;

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _dropdownValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Workout Creation'),
        ),
        body: const Center(
          child: Text('All questions answered!'),
        ),
      );
    }

    final current = _questions[_currentQuestionIndex];

    Widget questionWidget;
    if (current['type'] == 'dropdown') {
      List<String> options = List<String>.from(current['options']);
      questionWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(current['question']),
          const SizedBox(height: 16),
          DropdownButton<String>(
            hint: const Text('Select an option'),
            value: _dropdownValue,
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _dropdownValue = value;
              });
              Future.delayed(const Duration(milliseconds: 500), _nextQuestion);
            },
          ),
        ],
      );
    } else if (current['type'] == 'multiple') {
      List<String> options = List<String>.from(current['options']);
      questionWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(current['question']),
          const SizedBox(height: 16),
          // Display options in a column
          Column(
            children: options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(option),
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else {
      questionWidget = const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Creation'),
      ),
      body: Center(
        child: questionWidget,
      ),
    );
  }
}
