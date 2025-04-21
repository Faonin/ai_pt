import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'package:flutter/material.dart';
import 'package:ai_pt/src/ai_features/chat_messenger.dart';

class ActiveWorkoutProvider extends ChangeNotifier {
  String _currentWorkoutName = 'No workout selected';
  final assistantService = CustomAssistantService();
  late Map<String, dynamic> _currentExerciseDetails = {};
  late Map<String, dynamic> _currentUserExerciseInput = {};
  List<dynamic> _lastGeneratedWorkoutDetails = ["", DateTime.fromMillisecondsSinceEpoch(0)]; // [workoutName, lastUpdate]

  String get currentWorkout => _currentWorkoutName;

  Future<Map<String, dynamic>> get workoutAnaerobicDetails async {
    if (_currentWorkoutName == 'No workout selected') {
      return {
        "exercises": [
          {"name": "name", "sets": "sets", "reps": "reps", "weight": "weight"}
        ],
        "description": "No workout selected"
      };
    }
    Map<String, dynamic> workoutDetails = await WorkoutStorageManager().fetchItem(_currentWorkoutName);
      if (_currentExerciseDetails.isEmpty == true || workoutDetails["name"] != _lastGeneratedWorkoutDetails[0] || DateTime.now().difference(_lastGeneratedWorkoutDetails[1]).inHours >= 6) {       
        _lastGeneratedWorkoutDetails = [workoutDetails["name"], DateTime.now()];
        _currentExerciseDetails = await assistantService.getActiveAnaerobicWorkout(workoutDetails['description']);

      }
    return _currentExerciseDetails;
  }

  void createCurrentUserWorkout(Map<String, dynamic> workout) {


    notifyListeners();
  }

  void setCurrentWorkout(String workout) {
    _currentWorkoutName = workout;
    notifyListeners();
  }
}