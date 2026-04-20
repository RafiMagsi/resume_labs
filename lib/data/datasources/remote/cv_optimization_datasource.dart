import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../core/errors/app_exception.dart';

abstract interface class CvOptimizationDatasource {
  Future<String> optimizeCv(String cvText);
}

class CvOptimizationDatasourceImpl implements CvOptimizationDatasource {
  final http.Client _client;

  CvOptimizationDatasourceImpl(this._client);

  @override
  Future<String> optimizeCv(String cvText) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw AppException('OpenAI API key not configured');
      }

      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'temperature': 0.7,
          'max_tokens': 2000,
          'messages': [
            {
              'role': 'system',
              'content': '''You are a professional CV optimizer. Your task is to enhance the provided CV for maximum impact.

              - Improve weak bullet points with strong action verbs
              - Add relevant keywords from the industry
              - Enhance formatting and structure
              - Ensure proper grammar and professional tone
              - Keep the original content authentic and factual

              Return ONLY the optimized CV text, no explanations or markdown formatting.'''
            },
            {
              'role': 'user',
              'content': cvText,
            }
          ],
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw AppException('CV optimization request timed out'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = json['choices'][0]['message']['content'] as String?;

        if (content == null || content.isEmpty) {
          throw AppException('Empty response from OpenAI');
        }

        return content;
      } else if (response.statusCode == 401) {
        throw AppException('OpenAI API authentication failed');
      } else if (response.statusCode == 429) {
        throw AppException('Rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 500) {
        throw AppException('OpenAI service error. Please try again later.');
      } else {
        throw AppException(
          'Failed to optimize CV: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('CV optimization failed: $e');
    }
  }
}
