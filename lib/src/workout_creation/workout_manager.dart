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

  Future<List<Map<String, dynamic>>> getWorkoutDetails(String name) async {
    
    var workoutDetails = await WorkoutStorageManager().fetchItem(name);
    
    print(workoutDetails[0]['questions'] != null
        ? jsonDecode(workoutDetails[0]['questions'])
        : workoutDetails[0]['questions']);
    return [];
  }

  Future<void> deleteWorkoutPlan(String name) async {
    WorkoutStorageManager().removeItem(name);
  }
}
