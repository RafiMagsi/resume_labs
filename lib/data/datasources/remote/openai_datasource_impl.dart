import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../core/errors/app_exception.dart';
import 'openai_datasource.dart';

class OpenAiDataSourceImpl implements OpenAiDataSource {
  final http.Client client;

  const OpenAiDataSourceImpl(this.client);

  static const String _endpoint = 'https://api.openai.com/v1/responses';
  static const String _model = 'gpt-4o';
  static const int _maxOutputTokens = 1500;

  String get _apiKey {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.trim().isEmpty) {
      throw const ValidationException(
        'OpenAI API key is missing.',
        code: 'openai-api-key-missing',
      );
    }
    return key;
  }

  @override
  Future<String> generateSummary({
    required String jobTitle,
    required List<String> skills,
    required List<String> workHighlights,
  }) async {
    final prompt = '''
You are an expert resume writer.

Generate a concise, strong professional summary for a resume.

Job Title:
$jobTitle

Skills:
${skills.join(', ')}

Work Highlights:
${workHighlights.map((e) => '- $e').join('\n')}

Rules:
- Return plain text only
- 3 to 5 sentences
- Professional tone
- No markdown
- No headings
''';

    final rawText = await _sendTextRequest(
      prompt: prompt,
      temperature: 0.7,
    );

    return rawText.trim();
  }

  @override
  Future<String> improveBullet({
    required String bullet,
    String? jobTitle,
  }) async {
    final prompt = '''
You are an expert resume writer.

Improve this resume bullet point so it becomes clearer, stronger, and more results-oriented.

Job Title:
${jobTitle ?? 'Not specified'}

Original Bullet:
$bullet

Rules:
- Return plain text only
- Keep it as one bullet point
- No markdown
- No heading
- Keep it realistic and professional
''';

    final rawText = await _sendTextRequest(
      prompt: prompt,
      temperature: 0.7,
    );

    return rawText.trim();
  }

  @override
  Future<List<String>> suggestSkills({
    required String jobTitle,
    required List<String> existingSkills,
    String? personalSummary,
  }) async {
    final prompt = '''
You are an expert resume writer.

Suggest additional resume skills for this candidate.

Job Title:
$jobTitle

Existing Skills:
${existingSkills.join(', ')}

Personal Summary:
${personalSummary ?? ''}

Rules:
- Return valid JSON only
- No markdown
- No explanation
- Use this exact format:
{"skills":["skill 1","skill 2","skill 3","skill 4","skill 5"]}
- Suggest only relevant resume skills
- Do not repeat existing skills exactly
''';

    final rawText = await _sendTextRequest(
      prompt: prompt,
      temperature: 0.2,
    );

    try {
      final decoded = jsonDecode(rawText);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response is not a JSON object');
      }

      final skills = decoded['skills'];
      if (skills is! List) {
        throw const FormatException('Missing or invalid skills array');
      }

      return skills
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      throw const ServerException(
        'Failed to parse suggested skills response.',
        code: 'openai-parse-skills-failed',
      );
    }
  }

  Future<String> _sendTextRequest({
    required String prompt,
    required double temperature,
  }) async {
    final response = await client
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': _model,
            'input': prompt,
            'max_output_tokens': _maxOutputTokens,
            'temperature': temperature,
          }),
        )
        .timeout(const Duration(seconds: 15));

    _handleHttpStatus(response);

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final directText = decoded['output_text'];
      if (directText is String && directText.trim().isNotEmpty) {
        return directText;
      }

      final output = decoded['output'];
      if (output is List) {
        for (final item in output) {
          if (item is Map<String, dynamic>) {
            final content = item['content'];
            if (content is List) {
              for (final part in content) {
                if (part is Map<String, dynamic>) {
                  final text = part['text'];
                  if (text is String && text.trim().isNotEmpty) {
                    return text;
                  }
                }
              }
            }
          }
        }
      }

      throw const FormatException('No text content found in OpenAI response');
    } on FormatException {
      throw const ServerException(
        'Failed to parse OpenAI response.',
        code: 'openai-parse-failed',
      );
    } catch (_) {
      throw const ServerException(
        'Unexpected OpenAI response format.',
        code: 'openai-invalid-response-format',
      );
    }
  }

  void _handleHttpStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String fallbackMessage = 'OpenAI request failed.';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message is String && message.trim().isNotEmpty) {
            fallbackMessage = message;
          }
        }
      }
    } catch (_) {
      // ignore body parse failure and use fallback
    }

    switch (response.statusCode) {
      case 401:
        throw AuthException(
          fallbackMessage.isNotEmpty
              ? fallbackMessage
              : 'Invalid OpenAI authentication credentials.',
          code: '401',
        );
      case 429:
        throw NetworkException(
          fallbackMessage.isNotEmpty
              ? fallbackMessage
              : 'OpenAI rate limit exceeded. Please try again later.',
          code: '429',
        );
      case 500:
        throw ServerException(
          fallbackMessage.isNotEmpty
              ? fallbackMessage
              : 'OpenAI internal server error.',
          code: '500',
        );
      case 503:
        throw ServerException(
          fallbackMessage.isNotEmpty
              ? fallbackMessage
              : 'OpenAI service is temporarily unavailable.',
          code: '503',
        );
      default:
        throw ServerException(
          fallbackMessage,
          code: response.statusCode.toString(),
        );
    }
  }
}
