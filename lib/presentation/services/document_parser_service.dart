import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DocumentParserService {
  /// Extract text from DOCX file
  /// DOCX is a ZIP file containing XML files
  static Future<String> extractFromDocx(File file) async {
    try {
      final bytes = file.readAsBytesSync();

      if (bytes.isEmpty) {
        throw Exception('The file is empty. Please upload a valid resume document.');
      }

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
        throw Exception('This does not appear to be a valid DOCX file. Please upload a valid resume document.');
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

      final extractedText = buffer.toString().trim();

      if (extractedText.isEmpty) {
        throw Exception('The document contains no readable text. Please upload a valid resume with content.');
      }

      return extractedText;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to parse DOCX: The file may be corrupted. Please upload a valid resume document.');
    }
  }

  /// Extract text from PDF file using Syncfusion PDF text extractor
  static Future<String> extractFromPdf(File file) async {
    try {
      final bytes = file.readAsBytesSync();

      if (bytes.isEmpty) {
        throw Exception('The file is empty. Please upload a valid resume document.');
      }

      final PdfDocument document = PdfDocument(inputBytes: bytes);

      if (document.pages.count == 0) {
        document.dispose();
        throw Exception('The PDF file contains no pages. Please upload a valid resume document.');
      }

      final buffer = StringBuffer();

      // Extract text from all pages using PdfTextExtractor
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      for (int i = 1; i <= document.pages.count; i++) {
        final text =
            extractor.extractText(startPageIndex: i - 1, endPageIndex: i - 1);
        if (text.isNotEmpty) {
          buffer.writeln(text);
        }
      }

      document.dispose();

      final extractedText = buffer.toString().trim();

      if (extractedText.isEmpty) {
        throw Exception('The PDF contains no readable text. This may be a scanned image or protected PDF. Please upload a valid resume document with extractable text.');
      }

      return extractedText;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: The file may be corrupted or invalid. Please upload a valid resume document.');
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
