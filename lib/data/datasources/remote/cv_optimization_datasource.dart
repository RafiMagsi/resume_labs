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

      final response = await _client
          .post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'gpt-4o',
              'temperature': 0.2,
              'max_tokens': 3000,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '''You are a professional CV optimizer. Your task is to enhance the provided CV for maximum impact.

Respond ONLY with valid JSON, no markdown, no backticks, no explanation.

Use this exact JSON structure:
{
  "title": "Job Title/Professional Role",
  "personalSummary": "Enhanced 3-4 sentence professional summary",
  "workExperiences": [
    {
      "company": "Company Name",
      "role": "Job Title",
      "location": "City, Country",
      "startDate": "2020-01-15",
      "endDate": "2022-12-31",
      "isCurrentRole": false,
      "bulletPoints": ["Achievement with metrics", "Responsibility improved"]
    }
  ],
  "educations": [
    {
      "school": "University Name",
      "degree": "Bachelor/Master",
      "field": "Field of Study",
      "graduationDate": "2020-06-15",
      "gpa": "3.8"
    }
  ],
  "skills": [
    {"name": "Skill Name", "category": "Technical"},
    {"name": "Skill Name", "category": "Communication"}
  ]
}

Rules:
- Improve weak bullet points with strong action verbs
- Add relevant keywords from the industry
- Enhance with professional tone
- Keep content authentic and factual
- Preserve ALL information from the original resume: do not drop jobs, education entries, or skills
- Do not remove bullet points; rewrite/improve them, but keep the meaning and coverage
- Do not invent new companies, roles, degrees, or dates
- Use ISO date format (YYYY-MM-DD)
- Separate bullet points as array items
- Extract dates from the CV if available, use reasonable estimates if not

Skills Optimization:
- Include ALL existing skills from the CV
- For each skill, intelligently suggest 2-3 related or complementary skills based on the person's background
- Related skills should enhance the candidate's profile (e.g., if they know "Flutter", add "Dart", "Mobile Development", "UI/UX")
- If the CV mentions specific frameworks/libraries, add related tools from the same ecosystem
- Add industry-relevant skills that are missing (e.g., Git for developers, Figma for designers)
- Keep skill categories appropriate (Technical, Language, Soft Skills, Tools, etc)
- Ensure suggested skills are relevant to their role and experience level'''
                },
                {
                  'role': 'user',
                  'content': cvText,
                }
              ],
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw AppException('CV optimization request timed out'),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = json['choices'][0]['message']['content'] as String?;

        if (content == null || content.isEmpty) {
          throw AppException('Empty response from OpenAI');
        }

        // Validate that response is valid JSON
        try {
          jsonDecode(content);
        } catch (_) {
          throw AppException('Invalid JSON response from OpenAI');
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
