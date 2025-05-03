import 'dart:convert';
import 'package:ai_pt/src/storage_manager/workout_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ai_pt/src/storage_manager/training_logs_storage_manager.dart';

class CustomAssistantService {
  final String? apiKey = dotenv.env["open_ai_key"];
  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  Future<String> talkToChatGPT(List userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-2024-08-06",
          "response_format": {"type": "json_object"},
          "messages": userMessage,
          "max_tokens": 2500,
          "temperature": 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(decodedBody);
        return data['choices'][0]['message']['content'] ?? "No response";
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception("Error: ${errorData['error']['message']}");
      }
    } catch (e) {
      return "$e";
    }
  }

  Future<String> getADescriptionForAWorkout(List<Map<String, dynamic>> workout) async {
    List userMessage = [
      {
        "role": "user",
        "content":
            "JSON format {'description': answer in one big descriptive string that will be included in a prompt for ChatGTP to generate workouts, that does not add more than has not been agreed and encourages progressive overload} User input: $workout"
      }
    ];
    String response = await talkToChatGPT(userMessage);
    return response;
  }

  Future<String> getEncouragementMessage(String workoutSets) async {
    List userMessage = [
      {
        "role": "user",
        "content":
            "Generate a short motivational message for a somebody that just completed a set of $workoutSets, to keep them motivated to keep pushing them self. JSON format: {'message': 'message'}"
      }
    ];
    return jsonDecode(await talkToChatGPT(userMessage))["message"];
  }

  Future<String> getNotificationMessage(String timeOfDay) async {
    List userMessage = [
      {
        "role": "user",
        "content":
            "Generate a one manipulative message that will be sent as a notification that motivates the user to work towards their workout goals. Time of day $timeOfDay, current active workout descriptions ${await WorkoutStorageManager().fetchWorkoutDescriptions()}. JSON format: {'message': 'message'}"
      }
    ];
    return jsonDecode(await talkToChatGPT(userMessage))["message"];
  }

  Future<Map<String, dynamic>> getActiveAnaerobicWorkout(List<String> mood, String description) async {
    List userMessage = [
      {
        "role": "user",
        "content":
            "Generate todays workout that keeps progressive overload based on previous exercises in mind in mind, but also recovery. Current mood: ${mood[0]}, ${mood[1]}/5, ${mood[2]} Workout description: $description. Previous workouts: ${await TrainingLogsStorageManager().fetchItems(30)}. JSON format: {'exercises': [{'name': name of the exercises, 'sets': [{'set':'1', 'amount': 'amount of reps/time', 'unit': 'the unit, seconds/minutes/', 'dose': Use \"First-Time\" for all sets in that exercise if you don't know what weight is appropriate; or weight, or \"None\" for bodyweight exercises', 'dose_unit': 'If they weight is in kilo/meters/km or any other unit'}, {continue for as many sets as recommended}], 'description': explanation for why this exercise was chosen}]}."
      }
    ];
    String response = await talkToChatGPT(userMessage);
    return jsonDecode(response);
  }

  Future<Map<String, dynamic>> getActiveCardioWorkout(List<String> mood, String description) async {
    List userMessage = [
      {
        "role": "user",
        "content":
            "Generate today's cardio-focused workout that maintains progressive overload based on previous cardio sessions, while also considering recovery needs. Current mood: ${mood[0]}, ${mood[1]}/5, ${mood[2]}. Workout description: $description. Previous cardio sessions: ${await TrainingLogsStorageManager().fetchItems(30)}. JSON format: {'exercises': [{'name': 'name of the exercise', 'sets': [{'set': '1', 'amount': 'amount of time/distance', 'unit': 'seconds/minutes/meters/kilometers', 'dose': 'First-Time if pacing/difficulty is unknown, otherwise specify intensity (e.g., moderate, sprint, incline level), or 'None' for steady-state bodyweight cardio. Keep it to less then two words', 'dose_unit': 'unit of intensity if applicable, Keep it to less then two words. Must be given if dose is not \"None\"'}, {'continue': 'for as many sets as recommended'}], 'description': 'explanation for why this exercise was chosen'}]}"
      }
    ];
    String response = await talkToChatGPT(userMessage);
    return jsonDecode(response);
  }

  Future<Map<String, dynamic>> getActiveMobilityWorkout(List<String> mood, String description) async {
    List userMessage = [
      {
        "role": "user",
        "content":
            "Generate today's mobility workout that focuses on improving flexibility, joint health, and active range of motion, while considering previous exercises and recovery needs. Current mood: ${mood[0]}, ${mood[1]}/5, ${mood[2]}. Workout description: $description. Previous workouts: ${await TrainingLogsStorageManager().fetchItems(30)}. JSON format: {'exercises': [{'name': name of the exercise, 'sets': [{'set':'1', 'amount': 'amount of reps/time', 'unit': 'seconds/minutes/reps', 'dose': Always use \"None\" unless resistance is specified, 'dose_unit': 'unit if any (e.g., kilo/meters), otherwise leave as \"N/A\"'}, {continue for as many sets as recommended}], 'description': reason why this mobility exercise was selected based on recovery and mobility goals}]}."
      }
    ];
    String response = await talkToChatGPT(userMessage);
    return jsonDecode(response);
  }
}
