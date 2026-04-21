import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/errors/failure.dart';

/// Service for generating PDFs via Firebase Cloud Function.
///
/// Requires FIREBASE_PDF_FUNCTION_URL environment variable to be set.
/// Example: https://us-central1-project-id.cloudfunctions.net/generatePdf
class FirebasePdfService {
  final String? _cloudFunctionUrl;

  FirebasePdfService({String? cloudFunctionUrl})
    : _cloudFunctionUrl = cloudFunctionUrl;

  /// Generates a PDF from resume data.
  ///
  /// Returns PDF bytes on success, throws exception on failure.
  Future<List<int>> generateResumePdf({
    required Map<String, dynamic> resumeData,
    required String template,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final url = _cloudFunctionUrl;
    if (url == null || url.isEmpty) {
      throw ServerFailure(
        'Firebase PDF Cloud Function URL not configured. '
        'Set FIREBASE_PDF_FUNCTION_URL environment variable.'
      );
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'resumeData': resumeData,
          'template': template,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final errorBody = response.body;
        throw ServerFailure(
          'PDF generation failed: ${response.statusCode}. $errorBody'
        );
      }
    } on http.ClientException catch (e) {
      throw NetworkFailure('Network error during PDF generation: $e');
    } catch (e) {
      rethrow;
    }
  }
}
