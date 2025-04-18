import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          "model": "gpt-4o-mini",
          "response_format": {"type": "json_object"},
          "messages": userMessage,
          "max_tokens": 2000,
          "temperature": 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
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
            "JSON format {'description': answer in one big descriptive string that will be included in a promt for ChatGTP to generate workouts, that does not add more than has not been agreed and encourages progressive overload} User input: $workout"
      }
    ];
    String response = await talkToChatGPT(userMessage);
    return response;
  }

  Future<Map<String, dynamic>> getActiveAnaerobicWorkout(String desciption) async {
    List userMessage = [
      {
        "role": "user",
        "content":
            "JSON format {'excersies': [{'name': name of the excersice, 'sets': amout of sets, 'reps': amount of reps, 'weight': the weight of the excersise when applicable}], 'desciption': explination for why the excersices are chosen}. User input: $desciption"
      }
    ];
    String response = await talkToChatGPT(userMessage);
    return jsonDecode(response);
  }
}
