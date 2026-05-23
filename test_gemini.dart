import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final key = '';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$key';

  print('=== Test 1: Simple hello ===');
  try {
    final r1 = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{'parts': [{'text': 'Say hello in 3 words'}]}],
        'generationConfig': {'maxOutputTokens': 20},
      }),
    ).timeout(Duration(seconds: 30));
    print('Status: ' + r1.statusCode.toString());
    print('Body: ' + r1.body.substring(0, r1.body.length > 500 ? 500 : r1.body.length));
  } catch (e) {
    print('Error: ' + e.toString());
  }

  print('\n=== Test 2: JSON classification (like the app does) ===');
  try {
    final r2 = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [{'text': 'You are a document classifier. Return only valid JSON.'}]
        },
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': 'Classify this document. Filename: test.pdf. Content: This is a quarterly sales report for Q3 2024. Return JSON with keys: suggested_name, folder_name, summary, tags, confidence'}]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'maxOutputTokens': 512,
        },
      }),
    ).timeout(Duration(seconds: 30));
    print('Status: ' + r2.statusCode.toString());
    print('Body: ' + r2.body.substring(0, r2.body.length > 800 ? 800 : r2.body.length));
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
