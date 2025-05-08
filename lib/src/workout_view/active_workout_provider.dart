import 'dart:async';

import 'package:ai_pt/src/storage_manager/training_logs_storage_manager.dart';
import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'package:flutter/material.dart';
import 'package:ai_pt/src/ai_features/chat_messenger.dart';

class ActiveWorkoutProvider extends ChangeNotifier {
  String _currentWorkoutName = 'No workout selected';
  String _currentWorkoutType = 'No workout type selected';
  List<String> _currentWorkoutFlex = ['No workout selected', 'No workout type selected'];
  final assistantService = CustomAssistantService();
  late Map<String, dynamic> _currentExerciseDetails = {};
  late Map<String, dynamic> _currentUserExerciseInput = {};
  List<dynamic> _lastGeneratedWorkoutDetails = ["", DateTime.fromMillisecondsSinceEpoch(0)]; // [workoutName, lastUpdate]
  String _chatResponse = '';

  void setCurrentWorkout(String workout) {
    _currentWorkoutName = workout;
    notifyListeners();
  }

  setFlex(List<String> flex) {
    _currentWorkoutFlex = flex;
  }

  void setCurrentWorkoutType(String workoutType) {
    _currentWorkoutType = workoutType;
    notifyListeners();
  }

  String get chatResponse => _chatResponse;
  String get currentWorkoutType => _currentWorkoutType;
  Map<String, dynamic> get currentUserExerciseInput => _currentUserExerciseInput;
  String get currentWorkoutName => _currentWorkoutName;

  String get currentWorkout {
    if (DateTime.now().difference(_lastGeneratedWorkoutDetails[1]).inHours > 6) {
      _currentWorkoutName = 'No workout selected';
    }
    return _currentWorkoutName;
  }

  Future<Map<String, dynamic>> get workoutDetails async {
    if (_currentWorkoutName == 'No workout selected') {
      return {
        "exercises": [
          {"": ""}
        ],
        "description": "No workout selected"
      };
    }
    Map<String, dynamic> workoutDetails = await WorkoutStorageManager().fetchItem(_currentWorkoutName);
    if (_currentExerciseDetails.isEmpty == true ||
        workoutDetails["name"] != _lastGeneratedWorkoutDetails[0] ||
        DateTime.now().difference(_lastGeneratedWorkoutDetails[1]).inHours >= 6) {
      _lastGeneratedWorkoutDetails = [workoutDetails["name"], DateTime.now()];
      

      if (_currentWorkoutType == 'Strength' || _currentWorkoutType == 'Muscle Growth') {
        _currentExerciseDetails = await assistantService.getActiveAnaerobicWorkout(_currentWorkoutFlex, workoutDetails['description']);
      } else if (_currentWorkoutType == 'Cardio') {
        _currentExerciseDetails = await assistantService.getActiveCardioWorkout(_currentWorkoutFlex, workoutDetails['description']);
      } else {
        _currentExerciseDetails = await assistantService.getActiveMobilityWorkout(_currentWorkoutFlex, workoutDetails['description']);
      }

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
              if (set["dose"] != "None") "dose": null,
              if (set["dose"] != "None") "dose_unit": set["dose_unit"],
            };
          }).toList(),
        };
      }).toList(),
    };
    return _currentUserExerciseInput;
  }

  void saveCurrentUserWorkout() {
    _currentUserExerciseInput["exercises"] = _currentUserExerciseInput["exercises"]
        .map((exercise) {
          final filteredSets = exercise["sets"].where((set) {
            if (set.containsKey("dose")) {
              if (set["dose_unit"] != null) {
                return set["amount"] != null;
              } else {
                return set["amount"] != null && set["dose"] != null;
              }
            } else {
              return set["amount"] != null;
            }
          }).toList();
          exercise["sets"] = filteredSets;
          return exercise;
        })
        .where((exercise) => (exercise["sets"] as List).isNotEmpty)
        .toList();
    if (_currentUserExerciseInput.isNotEmpty) {
      for (var exercise in _currentUserExerciseInput["exercises"]) {
        for (var set in exercise["sets"]) {
          TrainingLogsStorageManager().addItem(
              _currentWorkoutName,
              _currentWorkoutType,
              DateTime.now().toIso8601String(),
              exercise["name"],
              set["set"].toString(),
              set["amount"].toString(),
              set["unit"],
              set.containsKey("dose") ? set["dose"].toString() : "",
              set.containsKey("dose_unit") ? set["dose_unit"].toString() : "",
              set.containsKey("RPE") ? set["RPE"].toString() : "");
        }
      }
    }
    _currentWorkoutName = 'No workout selected';
    _currentExerciseDetails = {};
    _currentUserExerciseInput = {};
  }

  void getChatResponse(String message, String type) async {
    _chatResponse = await assistantService.getChatResponse(message, type);
    notifyListeners();
  }

  void clearChatResponse() {
    _chatResponse = 'Hi how can I help you?';
    notifyListeners();
  }
}
