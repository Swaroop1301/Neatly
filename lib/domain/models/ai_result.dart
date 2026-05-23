/// Result from Claude AI document classification.
class AiResult {
  final String suggestedName;
  final String folderName;
  final String summary;
  final List<String> tags;
  final double confidence;

  const AiResult({
    required this.suggestedName,
    required this.folderName,
    required this.summary,
    required this.tags,
    required this.confidence,
  });

  factory AiResult.fromJson(Map<String, dynamic> json) => AiResult(
        suggestedName: json['suggested_name'] as String? ?? 'Untitled Document',
        folderName: json['folder_name'] as String? ?? 'General',
        summary: json['summary'] as String? ?? 'No summary available.',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      );
}
