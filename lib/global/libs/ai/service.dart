import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _openaiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: 'your_openai_key');
  static const String _openaiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(_openaiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openaiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate AI response');
    }
  }

  Future<String> generateCode(String description) async {
    final prompt = 'Generate Flutter/Dart code for: $description. Provide only the code without explanations.';
    return await generateResponse(prompt);
  }

  Future<String> analyzeCode(String code) async {
    final prompt = 'Analyze this code and suggest improvements: $code';
    return await generateResponse(prompt);
  }
}
