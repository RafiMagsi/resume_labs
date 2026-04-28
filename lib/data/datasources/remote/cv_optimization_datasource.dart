import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../core/errors/app_exception.dart';
import 'system_settings_datasource.dart';

abstract interface class CvOptimizationDatasource {
  Future<String> optimizeCv(String cvText);
}

class CvOptimizationDatasourceImpl implements CvOptimizationDatasource {
  final http.Client _client;
  final SystemSettingsDatasource _systemSettings;

  CvOptimizationDatasourceImpl(
    this._client, {
    required SystemSettingsDatasource systemSettings,
  }) : _systemSettings = systemSettings;

  Future<String> _getApiKey() async {
    final envKey = dotenv.env['OPENAI_API_KEY'];
    if (envKey != null && envKey.trim().isNotEmpty) {
      return envKey.trim();
    }

    final remoteKey = await _systemSettings.getOpenAiApiKey();
    if (remoteKey == null || remoteKey.trim().isEmpty) {
      throw AppException('OpenAI API key not configured');
    }

    return remoteKey.trim();
  }

  @override
  Future<String> optimizeCv(String cvText) async {
    try {
      // Clean and normalize input
      final cleanedText = _normalizeInput(cvText);

      // Validate that input looks like a resume
      final validationResult = _validateResumeInput(cleanedText);
      if (!validationResult.isValid) {
        throw AppException(validationResult.message);
      }

      final apiKey = await _getApiKey();

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

CRITICAL: Respond ONLY with valid JSON. No markdown, no backticks, no code blocks, no explanation, no extra text before or after JSON.
Your entire response must be ONLY the JSON object, nothing else.

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
            const Duration(seconds: 45),
            onTimeout: () =>
                throw AppException('CV optimization request timed out after 45 seconds. Check your internet connection.'),
          );

      if (response.statusCode == 200) {
        try {
          // Parse the top-level API response
          late Map<String, dynamic> apiResponse;
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is! Map<String, dynamic>) {
              throw AppException(
                'Failed to process the optimization. Please try again.',
              );
            }
            apiResponse = decoded;
          } catch (e) {
            if (e is AppException) rethrow;
            throw AppException(
              'Failed to process the optimization. Please try again.',
            );
          }

          final choices = apiResponse['choices'] as List?;

          if (choices == null || choices.isEmpty) {
            throw AppException('OpenAI returned no response. Please try again.');
          }

          final content = (choices[0] as Map<String, dynamic>?)
              ?['message']?['content'] as String?;

          if (content == null || content.isEmpty) {
            throw AppException('Failed to process the optimization. Please try again.');
          }

          // Validate that response is valid JSON with expected fields
          try {
            final parsed = _safeJsonDecode(content);
            if (parsed == null) {
              throw AppException(
                'Failed to process the optimization. Please try again with a different resume.',
              );
            }
            _validateResponseStructure(parsed);
          } catch (e) {
            if (e is AppException) rethrow;
            throw AppException(
              'Failed to process the optimization. Please try again.',
            );
          }

          return content;
        } on AppException {
          rethrow;
        } catch (e) {
          throw AppException(
            'Failed to process the optimization. Please try again.',
          );
        }
      } else if (response.statusCode == 401) {
        throw AppException('OpenAI API key is invalid. Please contact support.');
      } else if (response.statusCode == 429) {
        throw AppException('API rate limit exceeded. Please wait a moment and try again.');
      } else if (response.statusCode == 500 || response.statusCode == 503) {
        throw AppException('OpenAI service is temporarily unavailable. Please try again later.');
      } else {
        throw AppException(
          'Failed to optimize CV: Server returned ${response.statusCode}. Please check your connection and try again.',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('CV optimization failed: Check your internet connection and try again. Error: $e');
    }
  }

  String _normalizeInput(String input) {
    if (input.isEmpty) return input;

    // Remove control characters and normalize whitespace
    final normalized = input
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return normalized;
  }

  /// Extract valid JSON from response that may contain markdown or extra text
  String _extractJson(String content) {
    if (content.isEmpty) return content;

    String text = content.trim();

    // Remove markdown code blocks (```json ... ``` or ``` ... ```)
    text = text.replaceAll(RegExp(r'^```(?:json)?\s*', multiLine: true), '');
    text = text.replaceAll(RegExp(r'\s*```$', multiLine: true), '');

    text = text.trim();

    // Try to find JSON object { ... } if there's extra text
    final openBrace = text.indexOf('{');
    if (openBrace > 0) {
      // Find the matching closing brace
      int braceCount = 0;
      int closeBraceIndex = -1;

      for (int i = openBrace; i < text.length; i++) {
        if (text[i] == '{') {
          braceCount++;
        } else if (text[i] == '}') {
          braceCount--;
          if (braceCount == 0) {
            closeBraceIndex = i;
            break;
          }
        }
      }

      if (closeBraceIndex > openBrace) {
        text = text.substring(openBrace, closeBraceIndex + 1);
      }
    }

    return text.trim();
  }

  _ValidationResult _validateResumeInput(String cvText) {
    if (cvText.isEmpty) {
      return _ValidationResult(
        isValid: false,
        message: 'The document is empty. Please provide a valid resume document.',
      );
    }

    final text = cvText.toLowerCase();
    final wordCount = cvText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    // Must have minimum content
    if (wordCount < 15) {
      return _ValidationResult(
        isValid: false,
        message: 'The document is too short. Please provide a resume with at least 15 words containing professional information.',
      );
    }

    // Check for resume-related keywords (expanded list)
    final resumeKeywords = [
      'experience',
      'education',
      'skill',
      'work',
      'job',
      'employment',
      'degree',
      'university',
      'college',
      'professional',
      'summary',
      'objective',
      'certifications',
      'certification',
      'languages',
      'language',
      'projects',
      'project',
      'achievements',
      'achievement',
      'responsibilities',
      'responsibility',
      'qualifications',
      'qualification',
      'years',
      'background',
      'profile',
    ];

    final matchedKeywords = resumeKeywords
        .where((keyword) => text.contains(keyword))
        .toSet()
        .length;

    if (matchedKeywords < 1) {
      return _ValidationResult(
        isValid: false,
        message: 'This doesn\'t appear to be a resume. Please upload a document that includes professional information such as experience, education, or skills.',
      );
    }

    // Check if it contains mostly readable content
    final readableChars = cvText
        .split('')
        .where((char) => RegExp(r'[a-zA-Z0-9\s\.\,\-\:\;\(\)\&\@\#\$\%\*\+\=\[\]\{\}]').hasMatch(char))
        .length;

    final readableRatio = readableChars / cvText.length;

    if (readableRatio < 0.5) {
      return _ValidationResult(
        isValid: false,
        message: 'The document contains too much unreadable or corrupted content. Please ensure you\'ve uploaded a valid resume file (PDF, DOCX, or TXT).',
      );
    }

    // Check for suspicious patterns (binary data, encoding issues)
    final suspiciousRatio = cvText
        .split('')
        .where((char) => char.codeUnitAt(0) > 127 &&
            !RegExp(r'[À-ÿ]').hasMatch(char)) // Allow common accented characters
        .length / cvText.length;

    if (suspiciousRatio > 0.2) {
      return _ValidationResult(
        isValid: false,
        message: 'The document appears to be corrupted or in an unsupported format. Please re-save your resume as PDF, DOCX, or plain text.',
      );
    }

    return _ValidationResult(isValid: true, message: '');
  }

  Map<String, dynamic>? _safeJsonDecode(String jsonString) {
    try {
      // Extract valid JSON if there's extra text or markdown
      final cleanedJson = _extractJson(jsonString);

      final decoded = jsonDecode(cleanedJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _validateResponseStructure(Map<String, dynamic> parsed) {
    // Validate that response has expected resume structure
    final hasExpectedFields = parsed.containsKey('title') ||
        parsed.containsKey('personalSummary') ||
        parsed.containsKey('workExperiences') ||
        parsed.containsKey('educations') ||
        parsed.containsKey('skills');

    if (!hasExpectedFields) {
      throw AppException(
        'The optimization returned an unexpected format. Please ensure your resume has standard sections like experience, education, or skills.',
      );
    }

    // Validate field types if they exist
    if (parsed.containsKey('workExperiences') &&
        parsed['workExperiences'] is! List) {
      throw AppException('Invalid resume structure: work experiences format is incorrect.');
    }

    if (parsed.containsKey('educations') && parsed['educations'] is! List) {
      throw AppException('Invalid resume structure: education format is incorrect.');
    }

    if (parsed.containsKey('skills') && parsed['skills'] is! List) {
      throw AppException('Invalid resume structure: skills format is incorrect.');
    }
  }
}

class _ValidationResult {
  final bool isValid;
  final String message;

  _ValidationResult({required this.isValid, required this.message});
}
