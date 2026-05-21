import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  // final String _apiKey = "TESTING_KEY";

  Future<String> _loadPrompt(String key) async {
    final yamlString = await rootBundle.loadString(
      'assets/prompts/prompts.yaml',
    );

    final yamlMap = loadYaml(yamlString);

    return yamlMap['prompt'][key];
  }

  Future<String> sendMessage({
    required List<Map<String, String>> messages,
    required String promptKey,
  }) async {
    final systemPrompt = await _loadPrompt(promptKey);
    log("System Prompt loaded from yaml file: $systemPrompt");

    final finalMessages = [
    {
      "role": "system",
      "content": systemPrompt,
    },

    ...messages,
  ];
  log("Final messages to be sent to OpenAI API: ${finalMessages.toString()}");

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": finalMessages,
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("API Error: ${response.body}");
    }
  }
}
