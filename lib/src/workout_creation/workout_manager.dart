import 'package:ai_pt/src/ai_features/chat_messager.dart';
import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'dart:convert';

class WorkoutManager {
  Future<void> createWorkoutPlan(List<Map<String, dynamic>> answeredQuestions) async {
    WorkoutStorageManager().addWorkoutPlan(
      answeredQuestions[0]['answer'],
      "description",
      jsonEncode(answeredQuestions.sublist(1)),
    );
    String description = await CustomAssistantService().getADescriptionForAWorkout(answeredQuestions.sublist(1));
    WorkoutStorageManager().updateWorkoutPlan(
      answeredQuestions[0]['answer'],
      description,
      jsonEncode(answeredQuestions.sublist(1)),
    );
  }
}
