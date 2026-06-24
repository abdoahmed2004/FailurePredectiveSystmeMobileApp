import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_keys.dart';

const String _aiModel =
    String.fromEnvironment('AI_MODEL', defaultValue: 'google/gemini-2.5-flash');
const Duration _timeout = Duration(seconds: 30);

class GeminiChatService {
  final http.Client _client;

  GeminiChatService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> generateReply({
    required String userPrompt,
    List<GeminiChatTurn> history = const [],
  }) async {
    if (openRouterApiKey.isEmpty) {
      throw Exception(
        'OpenRouter API key is missing. Please check your api_keys.dart file.',
      );
    }

    final List<Map<String, dynamic>> messages = [
      {
        'role': 'system',
        'content': 'You are FPMS assistant for factory predictive maintenance. Keep answers clear, practical, and concise.'
      },
      ...history.map((turn) => turn.toApiContent()),
      {
        'role': 'user',
        'content': userPrompt,
      },
    ];

    final body = jsonEncode({
      'model': _aiModel,
      'messages': messages,
      'temperature': 0.4,
      'max_tokens': 512,
    });

    try {
      final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $openRouterApiKey',
              'HTTP-Referer': 'https://machinify.app', // Optional but recommended by OpenRouter
              'X-Title': 'Machinify FPMS', // Optional but recommended
            },
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return _extractTextFromResponse(response.body);
      }

      final message = _extractErrorMessage(response);
      final normalized = message.toLowerCase();

      if (response.statusCode == 429 ||
          normalized.contains('quota') ||
          normalized.contains('rate limit')) {
        throw Exception('API quota exceeded or rate limited. Please try again later.');
      }

      throw Exception(message);
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Could not parse API response.');
    } catch (e) {
      rethrow;
    }
  }

  String _extractTextFromResponse(String responseBody) {
    final Map<String, dynamic> data =
        jsonDecode(responseBody) as Map<String, dynamic>;
    
    final List<dynamic>? choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('API returned an empty response.');
    }

    final Map<String, dynamic>? message =
        choices.first['message'] as Map<String, dynamic>?;
    
    final String? text = message?['content']?.toString();
    
    if (text == null || text.trim().isEmpty) {
      throw Exception('API returned a blank message.');
    }
    
    return text.trim();
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final dynamic data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final msg = data['error']?['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          return msg;
        }
      }
    } catch (_) {}
    return 'API request failed (${response.statusCode}).';
  }
}

class GeminiChatTurn {
  final bool isUser;
  final String text;

  const GeminiChatTurn({required this.isUser, required this.text});

  Map<String, dynamic> toApiContent() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': text,
    };
  }
}
