import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../../core/constants.dart';

/// Extracts text content from PDF, DOCX, and PPTX files.
class DocumentParserService {
  /// Extract text from a PDF file.
  static Future<String> extractTextFromPdf(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final buffer = StringBuffer();
      
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        final text = PdfTextExtractor(document)
            .extractText(startPageIndex: i, endPageIndex: i);
        buffer.writeln(text);
      }
      
      document.dispose();
      final text = buffer.toString().trim();
      return text.length > AppConstants.maxTextExtractionLength
          ? text.substring(0, AppConstants.maxTextExtractionLength)
          : text;
    } catch (e) {
      return 'Error extracting PDF text: $e';
    }
  }

  /// Get page count from PDF.
  static Future<int?> getPdfPageCount(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final count = document.pages.count;
      document.dispose();
      return count;
    } catch (_) {
      return null;
    }
  }

  /// Extract text from a DOCX file.
  static Future<String> extractTextFromDocx(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final text = docxToText(bytes);
      return text.length > AppConstants.maxTextExtractionLength
          ? text.substring(0, AppConstants.maxTextExtractionLength)
          : text;
    } catch (e) {
      return 'Error extracting DOCX text: $e';
    }
  }

  /// Extract text from a PPTX file.
  /// PPTX is a ZIP. We unzip, find slide XML files, and extract text from <a:t> nodes.
  static Future<String> extractTextFromPptx(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final buffer = StringBuffer();
      final processedTexts = <String>{};

      // Sort slide files to process in order
      final slideFiles = archive.files
          .where(
              (f) => f.name.startsWith('ppt/slides/slide') && f.name.endsWith('.xml'))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      for (final file in slideFiles) {
        final content = String.fromCharCodes(file.content as List<int>);
        final doc = XmlDocument.parse(content);
        
        // Extract all text from <a:t> nodes
        final textNodes = doc.findAllElements('a:t');
        for (final node in textNodes) {
          final text = node.innerText.trim();
          // Skip duplicates (slide master text repeats)
          if (text.isNotEmpty && !processedTexts.contains(text)) {
            processedTexts.add(text);
            buffer.writeln(text);
          }
        }
      }

      final text = buffer.toString().trim();
      return text.length > AppConstants.maxTextExtractionLength
          ? text.substring(0, AppConstants.maxTextExtractionLength)
          : text;
    } catch (e) {
      return 'Error extracting PPTX text: $e';
    }
  }

  /// Extract text based on file type.
  static Future<String> extractText(String filePath, String fileType) async {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return extractTextFromPdf(filePath);
      case 'docx':
      case 'doc':
        return extractTextFromDocx(filePath);
      case 'pptx':
      case 'ppt':
        return extractTextFromPptx(filePath);
      default:
        return 'Unsupported file type: $fileType';
    }
  }

  /// Get page count for supported types.
  static Future<int?> getPageCount(String filePath, String fileType) async {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return getPdfPageCount(filePath);
      default:
        return null;
    }
  }
}
