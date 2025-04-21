import 'package:ai_pt/src/ai_features/chat_messenger.dart';
import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'dart:convert';

class WorkoutManager {
  Future<void> createWorkoutPlan(List<Map<String, dynamic>> answeredQuestions) async {
    WorkoutStorageManager().addWorkoutPlan(
      answeredQuestions[0]['answer'],
      answeredQuestions[0]['answer'],
      "description",
      jsonEncode(answeredQuestions.sublist(2)),
    );

    String description = await CustomAssistantService().getADescriptionForAWorkout(answeredQuestions.sublist(1));
    WorkoutStorageManager().updateWorkoutPlan(
      answeredQuestions[0]['answer'],
      answeredQuestions[1]['answer'],
      description,
      jsonEncode(answeredQuestions.sublist(2)),
    );
  }

  Future<void> updateWorkoutPlan(List<Map<String, dynamic>> answeredQuestions) async {
    WorkoutStorageManager().updateWorkoutPlan(
      answeredQuestions[0]['answer'],
      answeredQuestions[1]['answer'],
      "description",
      jsonEncode(answeredQuestions.sublist(2)),
    );
  }

  Future<Map<String, dynamic>> getWorkoutDetails(String name) async {
    Map<String, dynamic> workoutDetails = Map.of(await WorkoutStorageManager().fetchItem(name));

    workoutDetails.remove('description');
    workoutDetails.remove('workoutType');
    return workoutDetails;
  }

  Future<void> deleteWorkoutPlan(String name) async {
    WorkoutStorageManager().removeItem(name);
  }
}
