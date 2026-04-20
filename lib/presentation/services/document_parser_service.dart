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

  /// Extract text from PDF file using Syncfusion PDF text extractor
  static Future<String> extractFromPdf(File file) async {
    try {
      final bytes = file.readAsBytesSync();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final buffer = StringBuffer();

      // Extract text from all pages using PdfTextExtractor
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      for (int i = 1; i <= document.pages.count; i++) {
        final text = extractor.extractText(startPageIndex: i - 1, endPageIndex: i - 1);
        buffer.writeln(text);
      }

      document.dispose();
      return buffer.toString().trim();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
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
