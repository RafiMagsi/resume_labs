import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/errors/failure.dart';

/// Service for generating PDFs via Firebase Cloud Function.
///
/// Requires FIREBASE_PDF_FUNCTION_URL environment variable to be set.
/// Example: https://us-central1-project-id.cloudfunctions.net/generatePdf
class FirebasePdfService {
  final String? _cloudFunctionUrl;
  final FirebaseAuth _auth;

  FirebasePdfService({
    String? cloudFunctionUrl,
    FirebaseAuth? auth,
  })  : _cloudFunctionUrl = cloudFunctionUrl,
        _auth = auth ?? FirebaseAuth.instance;

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
      // Get Firebase ID token for authentication
      final user = _auth.currentUser;
      final idToken = await user?.getIdToken();

      final headers = {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      };

      debugPrint('[FirebasePdfService] Requesting PDF generation from: $url');
      debugPrint('[FirebasePdfService] Resume title: ${resumeData['title']}');
      debugPrint('[FirebasePdfService] Template: $template');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'resumeData': resumeData,
          'template': template,
        }),
      ).timeout(timeout);

      debugPrint('[FirebasePdfService] Response status code: ${response.statusCode}');
      debugPrint('[FirebasePdfService] Response content type: ${response.headers['content-type']}');
      debugPrint('[FirebasePdfService] Response size: ${response.bodyBytes.length} bytes');

      if (response.statusCode == 200) {
        debugPrint('[FirebasePdfService] PDF generated successfully');
        return response.bodyBytes;
      } else {
        final errorBody = response.body;
        debugPrint('[FirebasePdfService] Error response body: $errorBody');
        final errorMessage = response.statusCode == 403
            ? 'Cloud Function is not publicly accessible. Please check Firebase Console permissions.'
            : 'PDF generation failed: ${response.statusCode}. $errorBody';
        throw ServerFailure(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('[FirebasePdfService] Network error: $e');
      throw NetworkFailure('Network error during PDF generation: $e');
    } catch (e) {
      debugPrint('[FirebasePdfService] Unexpected error: $e');
      rethrow;
    }
  }
}
