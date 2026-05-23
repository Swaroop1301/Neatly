import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants.dart';
import '../../domain/models/ai_result.dart';

/// Service to interact with Gemini API for document classification.
class AiService {
  static const _secureStorage = FlutterSecureStorage();
  static const _apiKeyKey = 'gemini_api_key';

  /// Built-in API key (fallback).
  static const _builtInApiKey = 'AIzaSyDkONv0fbay0P3we_WkpH0iwHMmcRKZ070';

  /// Save API key securely.
  static Future<void> saveApiKey(String key) async {
    await _secureStorage.write(key: _apiKeyKey, value: key);
  }

  /// Get stored API key, falls back to built-in key.
  static Future<String> getApiKey() async {
    final stored = await _secureStorage.read(key: _apiKeyKey);
    if (stored != null && stored.isNotEmpty) return stored;
    return _builtInApiKey;
  }

  /// Delete stored API key.
  static Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }

  /// Check if API key is available (always true now with built-in).
  static Future<bool> hasApiKey() async => true;

  /// Validate API key with a test call.
  static Future<bool> validateApiKey(String key) async {
    try {
      final url =
          '${AppConstants.apiEndpoint}/${AppConstants.aiModel}:generateContent?key=$key';
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': 'Say hi'}
                  ]
                }
              ],
              'generationConfig': {'maxOutputTokens': 10},
            }),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Classify a document using Gemini AI.
  static Future<AiResult> classifyDocument({
    required String extractedText,
    required String originalFilename,
    required String fileType,
  }) async {
    final apiKey = await getApiKey();

    final systemPrompt =
        'You are an expert document classifier and naming specialist. '
        'Analyse the provided document text and return ONLY a valid JSON object. '
        'No explanation, no preamble, no markdown fences — pure JSON only.';

    final userPrompt =
        '''Analyse this document content and return a JSON object with exactly these fields:

{
  "suggested_name": "Clean, descriptive file name without extension. Use title case. Max 50 chars.",
  "folder_name": "Category folder this belongs in. Be consistent — reuse names like Finance, Work, Legal, Health, Travel, Education, Personal, Receipts, Contracts, Reports. Max 20 chars.",
  "summary": "One sentence plain-English description of what this document is. Max 100 chars.",
  "tags": ["array", "of", "3-6", "lowercase", "keyword", "tags"],
  "confidence": 0.95
}

Document filename: $originalFilename
Document type: $fileType
Document content (first ${AppConstants.maxTextExtractionLength} chars):
$extractedText''';

    int retries = 0;
    int delay = 3;

    while (retries < AppConstants.maxRetries) {
      try {
        final url =
            '${AppConstants.apiEndpoint}/${AppConstants.aiModel}:generateContent?key=$apiKey';

        final requestBody = {
          'system_instruction': {
            'parts': [
              {'text': systemPrompt}
            ]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': userPrompt}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'maxOutputTokens': 1024,
          },
        };

        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = body['candidates'] as List<dynamic>?;
          if (candidates == null || candidates.isEmpty) {
            throw Exception(
                'Gemini returned no candidates. Response: ${response.body.substring(0, 200)}');
          }

          final parts =
              candidates[0]['content']?['parts'] as List<dynamic>? ?? [];

          // Find the text part (skip any thinking parts)
          String? textContent;
          for (final part in parts) {
            if (part is Map<String, dynamic> && part.containsKey('text')) {
              textContent = part['text'] as String?;
              break;
            }
          }

          if (textContent == null || textContent.isEmpty) {
            throw Exception('Gemini returned empty text. Parts: $parts');
          }

          // Strip markdown fences if present
          String jsonStr = textContent.trim();
          if (jsonStr.startsWith('```')) {
            jsonStr = jsonStr
                .replaceFirst(RegExp(r'^```\w*\n?'), '')
                .replaceFirst(RegExp(r'\n?```$'), '');
          }

          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          return AiResult.fromJson(json);
        } else if (response.statusCode == 429) {
          retries++;
          await Future.delayed(Duration(seconds: delay));
          delay *= 2;
          continue;
        } else {
          throw Exception(
              'Gemini API error ${response.statusCode}: ${response.body.length > 300 ? response.body.substring(0, 300) : response.body}');
        }
      } on Exception catch (e) {
        final msg = e.toString();
        if (msg.contains('TimeoutException')) {
          throw Exception(
              'Gemini request timed out. Check your internet connection.');
        }
        if (msg.contains('SocketException') ||
            msg.contains('HandshakeException')) {
          throw Exception(
              'Network error. AI processing will resume when you reconnect.');
        }
        if (retries >= AppConstants.maxRetries - 1) rethrow;
        retries++;
        await Future.delayed(Duration(seconds: delay));
        delay *= 2;
      }
    }

    throw Exception('Failed after ${AppConstants.maxRetries} retries.');
  }
}
