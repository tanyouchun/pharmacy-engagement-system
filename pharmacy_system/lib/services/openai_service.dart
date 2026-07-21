import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for communicating with the OpenAI API.
/// It loads predefined prompts from a YAML file and generates
/// AI responses based on the provided user messages.
class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  /// Loads a predefined system prompt from the YAML file
  /// using the specified prompt key.
  Future<String> _loadPrompt(String key) async {
    final yamlString = await rootBundle.loadString(
      'assets/prompts/prompts.yaml',
    );

    final yamlMap = loadYaml(yamlString);

    return yamlMap['prompt'][key];
  }

  /// Sends a chat completion request to the OpenAI API.
  ///
  /// Workflow:
  /// 1. Load the corresponding system prompt.
  /// 2. Combine the system prompt with user messages.
  /// 3. Submit the request to the OpenAI API.
  /// 4. Return the generated AI response.
  Future<String> sendMessage({
    required List<Map<String, String>> messages,
    required String promptKey,
  }) async {
    // Load the system prompt from the YAML configuration.

    // Combine the system prompt with the conversation history.

    // Send the request to the OpenAI Chat Completions API.

    // Return the generated response if the request succeeds,
    // otherwise throw an exception.
    final systemPrompt = await _loadPrompt(promptKey);
    log("System Prompt loaded from yaml file: $systemPrompt");

    final finalMessages = [
      {"role": "system", "content": systemPrompt},

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
