import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const String _geminiApiKey =
  String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'AIzaSyBS2_rejcKOKExFHc6e99ouH5Pe6g2DXXo');
const String _geminiModel =
    String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-2.0-flash');
const Duration _geminiTimeout = Duration(seconds: 20);

class GeminiChatService {
  final http.Client _client;

  GeminiChatService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> generateReply({
    required String userPrompt,
    List<GeminiChatTurn> history = const [],
  }) async {
    if (_geminiApiKey.isEmpty) {
      throw Exception(
        'Gemini API key is missing. Run with --dart-define=GEMINI_API_KEY=YOUR_KEY',
      );
    }

    final List<Map<String, dynamic>> contents = [
      ...history.map((turn) => turn.toApiContent()),
      {
        'role': 'user',
        'parts': [
          {
            'text':
                'You are FPMS assistant for factory predictive maintenance. Keep answers clear, practical, and concise.\n\nUser question: $userPrompt'
          }
        ],
      },
    ];

    final body = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 512,
      },
    });

    try {
      final modelsToTry = <String>{
        _geminiModel,
        'gemini-2.0-flash',
        'gemini-2.0-flash-lite',
        'gemini-1.5-flash-latest',
        'gemini-1.5-pro-latest',
      }.toList();
      final versionsToTry = const ['v1', 'v1beta'];

      String? lastRecoverableError;
      for (final version in versionsToTry) {
        for (final model in modelsToTry) {
          final url = Uri.parse(
            'https://generativelanguage.googleapis.com/$version/models/$model:generateContent?key=$_geminiApiKey',
          );

          final response = await _client
              .post(
                url,
                headers: const {
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: body,
              )
              .timeout(_geminiTimeout);

          if (response.statusCode == 200) {
            return _extractTextFromResponse(response.body);
          }

          final message = _extractErrorMessage(response);
          final normalized = message.toLowerCase();

          if (response.statusCode == 429 ||
              normalized.contains('quota') ||
              normalized.contains('rate limit')) {
            throw Exception(_buildQuotaMessage(message));
          }

          final recoverable = response.statusCode == 404 ||
              normalized.contains('not found') ||
              normalized.contains('not supported for generatecontent');

          if (recoverable) {
            lastRecoverableError = message;
            continue;
          }

          throw Exception(message);
        }
      }

      throw Exception(
        lastRecoverableError ??
            'No compatible Gemini model was found for this API key/project.',
      );
    } on TimeoutException {
      throw Exception('Gemini request timed out. Please try again.');
    } on FormatException {
      throw Exception('Could not parse Gemini response.');
    } catch (e) {
      rethrow;
    }
  }

  String _extractTextFromResponse(String responseBody) {
    final Map<String, dynamic> data =
        jsonDecode(responseBody) as Map<String, dynamic>;
    final List<dynamic>? candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    final Map<String, dynamic>? content =
        candidates.first['content'] as Map<String, dynamic>?;
    final List<dynamic>? parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini returned no text parts.');
    }

    final text = parts
        .map((part) => (part as Map<String, dynamic>)['text']?.toString() ?? '')
        .join('\n')
        .trim();
    if (text.isEmpty) {
      throw Exception('Gemini returned a blank message.');
    }
    return text;
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
    return 'gemini request failed (${response.statusCode}).';
  }

  String _buildQuotaMessage(String apiMessage) {
    final waitMatch = RegExp(r'please retry in\s+([0-9.]+)s', caseSensitive: false)
        .firstMatch(apiMessage);
    final waitSeconds = waitMatch?.group(1);
    if (waitSeconds != null) {
      return 'Gemini quota exceeded. Retry after about $waitSeconds seconds, or use another API key with available quota.';
    }
    return 'Gemini quota exceeded. Please check your Google AI plan/billing or switch to another API key.';
  }
}

class GeminiChatTurn {
  final bool isUser;
  final String text;

  const GeminiChatTurn({required this.isUser, required this.text});

  Map<String, dynamic> toApiContent() {
    return {
      'role': isUser ? 'user' : 'model',
      'parts': [
        {'text': text}
      ],
    };
  }
}
