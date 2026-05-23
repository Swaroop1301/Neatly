import 'dart:convert';

/// Domain model for a document.
class DocumentModel {
  static const _unset = Object();

  final int? id;
  final int? folderId;
  final String originalName;
  final String? aiName;
  final String displayName;
  final String filePath;
  final String fileType;
  final int fileSizeBytes;
  final int? pageCount;
  final String? aiSummary;
  final List<String> aiTags;
  final String aiStatus; // pending | processing | done | failed
  final bool isFavourite;
  final DateTime? lastOpenedAt;
  final DateTime uploadedAt;
  final DateTime updatedAt;

  // Joined fields
  final String? folderName;
  final String? folderColorName;

  const DocumentModel({
    this.id,
    this.folderId,
    required this.originalName,
    this.aiName,
    required this.displayName,
    required this.filePath,
    required this.fileType,
    required this.fileSizeBytes,
    this.pageCount,
    this.aiSummary,
    this.aiTags = const [],
    this.aiStatus = 'pending',
    this.isFavourite = false,
    this.lastOpenedAt,
    required this.uploadedAt,
    required this.updatedAt,
    this.folderName,
    this.folderColorName,
  });

  DocumentModel copyWith({
    Object? id = _unset,
    Object? folderId = _unset,
    String? originalName,
    Object? aiName = _unset,
    String? displayName,
    String? filePath,
    String? fileType,
    int? fileSizeBytes,
    Object? pageCount = _unset,
    Object? aiSummary = _unset,
    List<String>? aiTags,
    String? aiStatus,
    bool? isFavourite,
    Object? lastOpenedAt = _unset,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    Object? folderName = _unset,
    Object? folderColorName = _unset,
  }) {
    return DocumentModel(
      id: id == _unset ? this.id : id as int?,
      folderId: folderId == _unset ? this.folderId : folderId as int?,
      originalName: originalName ?? this.originalName,
      aiName: aiName == _unset ? this.aiName : aiName as String?,
      displayName: displayName ?? this.displayName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      pageCount: pageCount == _unset ? this.pageCount : pageCount as int?,
      aiSummary:
          aiSummary == _unset ? this.aiSummary : aiSummary as String?,
      aiTags: aiTags ?? this.aiTags,
      aiStatus: aiStatus ?? this.aiStatus,
      isFavourite: isFavourite ?? this.isFavourite,
      lastOpenedAt: lastOpenedAt == _unset
          ? this.lastOpenedAt
          : lastOpenedAt as DateTime?,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      folderName:
          folderName == _unset ? this.folderName : folderName as String?,
      folderColorName: folderColorName == _unset
          ? this.folderColorName
          : folderColorName as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'folder_id': folderId,
        'original_name': originalName,
        'ai_name': aiName,
        'display_name': displayName,
        'file_path': filePath,
        'file_type': fileType,
        'file_size_bytes': fileSizeBytes,
        'page_count': pageCount,
        'ai_summary': aiSummary,
        'ai_tags': jsonEncode(aiTags),
        'ai_status': aiStatus,
        'is_favourite': isFavourite ? 1 : 0,
        'last_opened_at': lastOpenedAt?.millisecondsSinceEpoch,
        'uploaded_at': uploadedAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    List<String> parseTags(dynamic tagsRaw) {
      if (tagsRaw == null) return [];
      if (tagsRaw is List) return tagsRaw.cast<String>();
      if (tagsRaw is String) {
        try {
          final decoded = jsonDecode(tagsRaw);
          if (decoded is List) return decoded.cast<String>();
        } catch (_) {}
      }
      return [];
    }

    return DocumentModel(
      id: map['id'] as int?,
      folderId: map['folder_id'] as int?,
      originalName: map['original_name'] as String,
      aiName: map['ai_name'] as String?,
      displayName: map['display_name'] as String,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      fileSizeBytes: map['file_size_bytes'] as int,
      pageCount: map['page_count'] as int?,
      aiSummary: map['ai_summary'] as String?,
      aiTags: parseTags(map['ai_tags']),
      aiStatus: map['ai_status'] as String? ?? 'pending',
      isFavourite: (map['is_favourite'] as int?) == 1,
      lastOpenedAt: map['last_opened_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_opened_at'] as int)
          : null,
      uploadedAt:
          DateTime.fromMillisecondsSinceEpoch(map['uploaded_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      folderName: map['folder_name'] as String?,
      folderColorName: map['folder_color_name'] as String?,
    );
  }
}
