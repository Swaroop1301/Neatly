/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Neatly';
  static const String appVersion = '1.0.0';
  static const String apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String aiModel = 'gemini-2.5-flash';
  static const int maxTextExtractionLength = 6000;
  static const int maxSummaryLength = 100;
  static const int maxNameLength = 50;
  static const int searchDebounceMs = 250;
  static const int maxRecentSearches = 8;
  static const int maxRetries = 3;
  static const String filesSubdir = 'neatly_files';

  // Supported file types
  static const supportedExtensions = ['pdf', 'docx', 'pptx'];
  static const supportedMimeTypes = [
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  ];
}
