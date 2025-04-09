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
          "max_tokens": 1100,
          "temperature": 0.85,
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
            "JSON format {description: answser in one big descripting string that could be used to generate workouts, that does not add more than has not been agreed} User input: $workout"
      }
    ];
    String response = await talkToChatGPT(userMessage);
    print(response);
    return response;
  }
}
