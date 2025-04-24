import 'package:flutter/material.dart';
import 'package:ai_pt/src/workout_creation/workout_manager.dart';

class WorkoutCreationView extends StatefulWidget {
  const WorkoutCreationView({super.key});

  static const routeName = '/workout_creation';

  @override
  WorkoutCreationViewState createState() => WorkoutCreationViewState();
}

class WorkoutCreationViewState extends State<WorkoutCreationView> {
  final List<Map<String, dynamic>> _questions = [
    {
      'type': 'free_text',
      'question': 'Enter the name of the workout:',
      'mandatory': true,
    },
    {
      'type': 'multiple',
      'question': 'What type of training do you prefer?',
      'options': ['Strength', 'Muscle Growth', 'Cardio', 'Flexibility'],
    },
    {
      'type': 'free_text',
      'question': 'What is your preferred workout  (in minutes)?',
      'mandatory': true,
    },
    {
      'type': 'free_text',
      'question': 'What is your primary fitness goal?',
      'mandatory': true,
    },
    {
      'type': 'multiple',
      'question': 'How would you rate your current fitness level?',
      'options': ['Beginner', 'Intermediate', 'Advanced'],
    },
    {
      'type': 'dropdown',
      'question': 'How many days per week can you commit to training?',
      'options': ['1-2 days', '3-4 days', '5-7 days'],
    },
    {
      'type': 'free_text',
      'question': 'Do you have any specific health concerns or injuries?',
    },
    {
      'type': 'multiple',
      'question': 'How intense do you prefer your workouts?',
      'options': ['Light', 'Moderate', 'Intense'],
    },
    {
      'type': 'free_text',
      'question': 'Any additional information or goals you’d like to share?',
    },
  ];

  int _currentQuestionIndex = 0;
  String? _dropdownValue;
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> answeredQuestions = [];

  void _nextQuestion(Map<String, dynamic> answeredQuestion) {
    setState(() {
      answeredQuestions.add(answeredQuestion);
      _currentQuestionIndex++;
      _dropdownValue = null;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= _questions.length) {
      WorkoutManager().createWorkoutPlan(answeredQuestions);
      Future.delayed(const Duration(milliseconds: 200), () {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });

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
              Future.delayed(
                const Duration(milliseconds: 300),
                () => _nextQuestion({
                  "question": current["question"],
                  "answer": value,
                }),
              );
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
          Column(
            children: options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () => _nextQuestion({
                    "question": current["question"],
                    "answer": option,
                  }),
                  child: Text(option),
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else if (current['type'] == 'free_text') {
      questionWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(current['question']),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your answer',
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (current['mandatory'] == true && _textController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This field is mandatory.")),
                );
              } else {
                _nextQuestion({
                  "question": current["question"],
                  "answer": _textController.text,
                });
                _textController.clear();
              }
            },
            child: const Text('Submit'),
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
