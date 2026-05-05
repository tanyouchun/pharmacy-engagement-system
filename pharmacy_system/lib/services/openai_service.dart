import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  // final String _apiKey = "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";
  final String _apiKey = "TESTING_KEY";

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": """
                      You are a pharmacy assistant chatbot.

                      Rules:
                      - Provide general medication information only
                      - Do NOT diagnose diseases
                      - Keep answers short and clear (limit to 100 words)
                      - If user ask for other questions not related to healthcare, answer in a friendly manner about your pharmacy assistant role, but do not provide information outside of that scope
                      - If the question is serious, advise consulting a pharmacist
                      """,
          },
          ...messages,
        ],
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
