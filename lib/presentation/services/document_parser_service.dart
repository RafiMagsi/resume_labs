import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

class DocumentParserService {
  /// Extract text from DOCX file
  /// DOCX is a ZIP file containing XML files
  static Future<String> extractFromDocx(File file) async {
    try {
      final bytes = file.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find document.xml in the archive
      ArchiveFile? documentFile;
      for (var file in archive) {
        if (file.name == 'word/document.xml') {
          documentFile = file;
          break;
        }
      }

      if (documentFile == null) {
        throw Exception('No document.xml found in DOCX');
      }

      // Extract and parse the XML
      final xmlContent = String.fromCharCodes(documentFile.content);
      final document = xml.XmlDocument.parse(xmlContent);

      // Extract all text from paragraphs
      final buffer = StringBuffer();
      final textElements = document.findAllElements('t');

      for (var element in textElements) {
        buffer.write(element.innerText);
      }

      return buffer.toString().trim();
    } catch (e) {
      throw Exception('Failed to parse DOCX: $e');
    }
  }

  /// Extract text from PDF file
  /// Note: This is a simplified approach using pdfx package
  static Future<String> extractFromPdf(File file) async {
    try {
      // For now, return a placeholder message
      // PDF text extraction requires additional dependencies
      // User should paste content manually for now
      return '''PDF text extraction requires additional setup.
Please copy and paste your resume content from the PDF instead.

To upload a PDF:
1. Open your PDF in Adobe Reader or similar
2. Select all text (Ctrl+A or Cmd+A)
3. Copy it (Ctrl+C or Cmd+C)
4. Return to this app and paste into the text field above''';
    } catch (e) {
      throw Exception('Failed to parse PDF: $e');
    }
  }

  /// Get file type from path
  static String getFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return extension;
  }

  /// Check if file type is supported
  static bool isSupportedFileType(String filePath) {
    final type = getFileType(filePath);
    return ['docx', 'pdf', 'doc'].contains(type);
  }
}
