/// Domain model for a folder.
class FolderModel {
  final int? id;
  final String name;
  final String colorName;
  final String iconName;
  final bool isAiGenerated;
  final DateTime createdAt;
  final int sortOrder;
  final int documentCount;

  const FolderModel({
    this.id,
    required this.name,
    this.colorName = 'Violet',
    this.iconName = 'PhFolder',
    this.isAiGenerated = true,
    required this.createdAt,
    this.sortOrder = 0,
    this.documentCount = 0,
  });

  FolderModel copyWith({
    int? id,
    String? name,
    String? colorName,
    String? iconName,
    bool? isAiGenerated,
    DateTime? createdAt,
    int? sortOrder,
    int? documentCount,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorName: colorName ?? this.colorName,
      iconName: iconName ?? this.iconName,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      documentCount: documentCount ?? this.documentCount,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'color_name': colorName,
        'icon_name': iconName,
        'is_ai_generated': isAiGenerated ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'sort_order': sortOrder,
      };

  factory FolderModel.fromMap(Map<String, dynamic> map) => FolderModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        colorName: map['color_name'] as String? ?? 'Violet',
        iconName: map['icon_name'] as String? ?? 'PhFolder',
        isAiGenerated: (map['is_ai_generated'] as int?) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        sortOrder: map['sort_order'] as int? ?? 0,
        documentCount: map['document_count'] as int? ?? 0,
      );
}
