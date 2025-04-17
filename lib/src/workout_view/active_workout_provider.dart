import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'package:flutter/material.dart';
import 'package:ai_pt/src/ai_features/chat_messager.dart';

class ActiveWorkoutProvider extends ChangeNotifier {
  String _currentWorkout = 'No workout selected';
  Map<String, dynamic> _workoutDetails = {
    "exercises": [
      {"name": "name", "sets": "sets", "reps": "reps", "weight": "weight"}
    ],
    "description": "chosen"
  };
  final assistantService = CustomAssistantService();

  String get currentWorkout => _currentWorkout;
  Map<String, dynamic> get workoutDetails => _workoutDetails;

  void setCurrentWorkout(String workout) async {
    _currentWorkout = workout;

    notifyListeners();

    var description = await WorkoutStorageManager().fetchItem(_currentWorkout);
    _workoutDetails = await assistantService.getActiveWorkout(description[0]['description']);

    notifyListeners();
  }
}
