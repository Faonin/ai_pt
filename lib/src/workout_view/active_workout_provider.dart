import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'package:flutter/material.dart';
import 'package:ai_pt/src/ai_features/chat_messenger.dart';

class ActiveWorkoutProvider extends ChangeNotifier {
  String _currentWorkoutName = 'No workout selected';
  final assistantService = CustomAssistantService();
  late Map<String, dynamic> _currentExerciseDetails = {};
  late Map<String, dynamic> _currentUserExerciseInput = {};
  List<dynamic> _lastGeneratedWorkoutDetails = [
    "",
    DateTime.fromMillisecondsSinceEpoch(0)
  ]; // [workoutName, lastUpdate]

  void setCurrentWorkout(String workout) {
    _currentWorkoutName = workout;
    notifyListeners();
  }

  String get currentWorkout => _currentWorkoutName;
  Map<String, dynamic> get currentUserExerciseInput =>
      _currentUserExerciseInput;

  Future<Map<String, dynamic>> get workoutDetails async {
    if (_currentWorkoutName == 'No workout selected') {
      return {
        "exercises": [
          {"name": "name", "sets": "sets", "reps": "reps", "weight": "weight"}
        ],
        "description": "No workout selected"
      };
    }
    Map<String, dynamic> workoutDetails =
        await WorkoutStorageManager().fetchItem(_currentWorkoutName);
    if (_currentExerciseDetails.isEmpty == true ||
        workoutDetails["name"] != _lastGeneratedWorkoutDetails[0] ||
        DateTime.now().difference(_lastGeneratedWorkoutDetails[1]).inHours >=
            6) {
      _lastGeneratedWorkoutDetails = [workoutDetails["name"], DateTime.now()];
      _currentExerciseDetails = await assistantService
          .getActiveAnaerobicWorkout(workoutDetails['description']);
      createCurrentUserWorkout(_currentExerciseDetails);
    }
    return _currentExerciseDetails;
  }

  Map<String, dynamic> createCurrentUserWorkout(Map<String, dynamic> workout) {
    _currentUserExerciseInput = {
      "exercises": workout["exercises"].map((exercise) {
        return {
          "name": exercise["name"],
          "sets": exercise["sets"].map((set) {
            return {
              "set": set["set"],
              "amount": null,
              "unit": set["unit"],
              if (set["weight"] != "None") "weight": null,
            };
          }).toList(),
        };
      }).toList(),
    };
    return _currentUserExerciseInput;
  }

  void saveCurrentUserWorkout() {
    print(_currentUserExerciseInput);
  }
}
