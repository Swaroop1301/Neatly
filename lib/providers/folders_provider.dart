import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';
import '../domain/models/folder.dart';
import 'database_provider.dart';

/// Notifier for folder operations.
class FoldersNotifier extends StateNotifier<AsyncValue<List<FolderModel>>> {
  final AppDatabase _db;

  FoldersNotifier(this._db) : super(const AsyncValue.loading()) {
    loadFolders();
  }

  Future<void> loadFolders() async {
    try {
      state = const AsyncValue.loading();
      final folders = await _db.getAllFolders();
      state = AsyncValue.data(folders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> createFolder({
    required String name,
    String colorName = 'Violet',
    String iconName = 'PhFolder',
    bool isAiGenerated = false,
  }) async {
    final folder = FolderModel(
      name: name,
      colorName: colorName,
      iconName: iconName,
      isAiGenerated: isAiGenerated,
      createdAt: DateTime.now(),
    );
    final id = await _db.insertFolder(folder);
    await loadFolders();
    return id;
  }

  Future<FolderModel?> getOrCreateFolder(String name) async {
    var folder = await _db.getFolderByName(name);
    if (folder != null) return folder;

    // Auto-assign color from palette cycling
    final count = await _db.getFolderCount();
    final colorIndex = count % 8;
    final colorNames = [
      'Violet', 'Rose', 'Amber', 'Emerald', 'Sky', 'Coral', 'Slate', 'Plum'
    ];

    final id = await createFolder(
      name: name,
      colorName: colorNames[colorIndex],
      isAiGenerated: true,
    );

    return _db.getFolderById(id);
  }

  Future<void> updateFolder(FolderModel folder) async {
    await _db.updateFolder(folder);
    await loadFolders();
  }

  Future<void> deleteFolder(int id) async {
    await _db.deleteFolder(id);
    await loadFolders();
  }
}

final foldersProvider =
    StateNotifierProvider<FoldersNotifier, AsyncValue<List<FolderModel>>>(
        (ref) {
  final db = ref.watch(databaseProvider);
  return FoldersNotifier(db);
});
