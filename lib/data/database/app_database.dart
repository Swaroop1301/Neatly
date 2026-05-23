import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../domain/models/folder.dart';
import '../../domain/models/document.dart';

/// SQLite database using raw sqflite (not Drift code-gen).
/// Includes FTS5 virtual table for full-text search.
class AppDatabase {
  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'neatly.db');

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS || Platform.isAndroid)) {
      // Use FFI (bundled SQLite) to ensure FTS5 support across all platforms, especially Android
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      return databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    } else {
      // Fallback for iOS or other platforms where system SQLite is reliable/required
      return openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    final sqliteVersion = await db.rawQuery('SELECT sqlite_version()');
    print('SQLite version: ${sqliteVersion.first.values.first}');

    try {
      final modules = await db.rawQuery('SELECT * FROM pragma_module_list()');
      print('Available modules: ${modules.map((m) => m['name']).join(', ')}');
    } catch (e) {
      print('Could not query pragma_module_list: $e');
    }

    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color_name TEXT NOT NULL DEFAULT 'Violet',
        icon_name TEXT NOT NULL DEFAULT 'PhFolder',
        is_ai_generated INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_id INTEGER REFERENCES folders(id) ON DELETE SET NULL,
        original_name TEXT NOT NULL,
        ai_name TEXT,
        display_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size_bytes INTEGER NOT NULL,
        page_count INTEGER,
        ai_summary TEXT,
        ai_tags TEXT NOT NULL DEFAULT '[]',
        ai_status TEXT NOT NULL DEFAULT 'pending',
        is_favourite INTEGER NOT NULL DEFAULT 0,
        last_opened_at INTEGER,
        uploaded_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // FTS5 virtual table for full-text search
    await db.execute('''
      CREATE VIRTUAL TABLE document_fts USING fts5(
        doc_id UNINDEXED,
        display_name,
        ai_summary,
        full_text_content,
        ai_tags
      )
    ''');

    await db.execute('''
      CREATE TABLE recent_searches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        searched_at INTEGER NOT NULL
      )
    ''');
  }

  // ──── FOLDER OPERATIONS ────

  Future<int> insertFolder(FolderModel folder) async {
    final db = await database;
    return db.insert('folders', folder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<FolderModel>> getAllFolders() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT f.*, COUNT(d.id) AS document_count
      FROM folders f
      LEFT JOIN documents d ON d.folder_id = f.id
      GROUP BY f.id
      ORDER BY f.sort_order ASC, f.name ASC
    ''');
    return result.map((m) => FolderModel.fromMap(m)).toList();
  }

  Future<FolderModel?> getFolderByName(String name) async {
    final db = await database;
    final result = await db.query(
      'folders',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
    );
    if (result.isEmpty) return null;
    return FolderModel.fromMap(result.first);
  }

  Future<FolderModel?> getFolderById(int id) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT f.*, COUNT(d.id) AS document_count
      FROM folders f
      LEFT JOIN documents d ON d.folder_id = f.id
      WHERE f.id = ?
      GROUP BY f.id
    ''', [id]);
    if (result.isEmpty) return null;
    return FolderModel.fromMap(result.first);
  }

  Future<int> updateFolder(FolderModel folder) async {
    final db = await database;
    return db.update('folders', folder.toMap(),
        where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getFolderCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as cnt FROM folders');
    return result.first['cnt'] as int;
  }

  // ──── DOCUMENT OPERATIONS ────

  Future<int> insertDocument(DocumentModel doc) async {
    final db = await database;
    return db.insert('documents', doc.toMap());
  }

  Future<List<DocumentModel>> getAllDocuments({
    String? orderBy,
    int? limit,
    String? fileTypeFilter,
    bool? favouritesOnly,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (fileTypeFilter != null) {
      where.add('d.file_type = ?');
      args.add(fileTypeFilter);
    }
    if (favouritesOnly == true) {
      where.add('d.is_favourite = 1');
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final orderClause = orderBy ?? 'd.uploaded_at DESC';
    final limitClause = limit != null ? 'LIMIT $limit' : '';

    final result = await db.rawQuery('''
      SELECT d.*, f.name AS folder_name, f.color_name AS folder_color_name
      FROM documents d
      LEFT JOIN folders f ON d.folder_id = f.id
      $whereClause
      ORDER BY $orderClause
      $limitClause
    ''', args);
    return result.map((m) => DocumentModel.fromMap(m)).toList();
  }

  Future<List<DocumentModel>> getDocumentsByFolder(int folderId,
      {String? fileTypeFilter, bool? favouritesOnly}) async {
    final db = await database;
    final where = ['d.folder_id = ?'];
    final args = <dynamic>[folderId];

    if (fileTypeFilter != null) {
      where.add('d.file_type = ?');
      args.add(fileTypeFilter);
    }
    if (favouritesOnly == true) {
      where.add('d.is_favourite = 1');
    }

    final result = await db.rawQuery('''
      SELECT d.*, f.name AS folder_name, f.color_name AS folder_color_name
      FROM documents d
      LEFT JOIN folders f ON d.folder_id = f.id
      WHERE ${where.join(' AND ')}
      ORDER BY d.uploaded_at DESC
    ''', args);
    return result.map((m) => DocumentModel.fromMap(m)).toList();
  }

  Future<DocumentModel?> getDocumentById(int id) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT d.*, f.name AS folder_name, f.color_name AS folder_color_name
      FROM documents d
      LEFT JOIN folders f ON d.folder_id = f.id
      WHERE d.id = ?
    ''', [id]);
    if (result.isEmpty) return null;
    return DocumentModel.fromMap(result.first);
  }

  Future<int> updateDocument(DocumentModel doc) async {
    final db = await database;
    return db.update('documents', doc.toMap(),
        where: 'id = ?', whereArgs: [doc.id]);
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    // Also delete from FTS
    await db.delete('document_fts',
        where: 'doc_id = ?', whereArgs: [id.toString()]);
    return db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavourite(int id, bool isFavourite) async {
    final db = await database;
    await db.update('documents', {'is_favourite': isFavourite ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDocumentAiResult({
    required int id,
    required String aiName,
    required String aiSummary,
    required List<String> aiTags,
    required int? folderId,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'documents',
      {
        'ai_name': aiName,
        'display_name': aiName,
        'ai_summary': aiSummary,
        'ai_tags': jsonEncode(aiTags),
        'folder_id': folderId,
        'ai_status': 'done',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateAiStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'documents',
      {
        'ai_status': status,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<DocumentModel>> getPendingDocuments() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT d.*, f.name AS folder_name, f.color_name AS folder_color_name
      FROM documents d
      LEFT JOIN folders f ON d.folder_id = f.id
      WHERE d.ai_status IN ('pending', 'processing')
      ORDER BY d.uploaded_at ASC
    ''');
    return result.map((m) => DocumentModel.fromMap(m)).toList();
  }

  Future<int> getDocumentCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as cnt FROM documents');
    return result.first['cnt'] as int;
  }

  Future<int> getThisWeekDocumentCount() async {
    final db = await database;
    final weekAgo =
        DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM documents WHERE uploaded_at > ?',
        [weekAgo]);
    return result.first['cnt'] as int;
  }

  Future<Map<String, int>> getStorageByType() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT file_type, SUM(file_size_bytes) AS total_size
      FROM documents
      GROUP BY file_type
    ''');
    final map = <String, int>{};
    for (final row in result) {
      map[row['file_type'] as String] = (row['total_size'] as int?) ?? 0;
    }
    return map;
  }

  // ──── FTS OPERATIONS ────

  Future<void> indexDocument({
    required int docId,
    required String displayName,
    required String? aiSummary,
    required String? fullTextContent,
    required List<String> aiTags,
  }) async {
    final db = await database;
    // Delete old FTS entry
    await db.delete('document_fts',
        where: 'doc_id = ?', whereArgs: [docId.toString()]);
    // Insert new
    await db.insert('document_fts', {
      'doc_id': docId.toString(),
      'display_name': displayName,
      'ai_summary': aiSummary ?? '',
      'full_text_content': (fullTextContent ?? '').length > 5000
          ? fullTextContent!.substring(0, 5000)
          : fullTextContent ?? '',
      'ai_tags': aiTags.join(' '),
    });
  }

  Future<List<DocumentModel>> searchDocuments(String query) async {
    final db = await database;
    if (query.trim().isEmpty) return [];

    // Use FTS5 MATCH with prefix search
    final ftsQuery = '${query.trim()}*';
    final ftsResults = await db.rawQuery('''
      SELECT doc_id FROM document_fts
      WHERE document_fts MATCH ?
      ORDER BY rank
    ''', [ftsQuery]);

    if (ftsResults.isEmpty) return [];

    final ids = ftsResults.map((r) => r['doc_id'] as String).toList();
    final placeholders = ids.map((_) => '?').join(',');

    final result = await db.rawQuery('''
      SELECT d.*, f.name AS folder_name, f.color_name AS folder_color_name
      FROM documents d
      LEFT JOIN folders f ON d.folder_id = f.id
      WHERE d.id IN ($placeholders)
      ORDER BY d.uploaded_at DESC
    ''', ids.map((id) => int.parse(id)).toList());

    return result.map((m) => DocumentModel.fromMap(m)).toList();
  }

  // ──── RECENT SEARCHES ────

  Future<void> addRecentSearch(String query) async {
    final db = await database;
    // Remove duplicates
    await db.delete('recent_searches',
        where: 'LOWER(query) = LOWER(?)', whereArgs: [query]);
    await db.insert('recent_searches', {
      'query': query,
      'searched_at': DateTime.now().millisecondsSinceEpoch,
    });
    // Keep only last 8
    await db.execute('''
      DELETE FROM recent_searches WHERE id NOT IN (
        SELECT id FROM recent_searches ORDER BY searched_at DESC LIMIT 8
      )
    ''');
  }

  Future<List<String>> getRecentSearches() async {
    final db = await database;
    final result = await db.query(
      'recent_searches',
      orderBy: 'searched_at DESC',
      limit: 8,
    );
    return result.map((r) => r['query'] as String).toList();
  }

  Future<void> deleteRecentSearch(String query) async {
    final db = await database;
    await db.delete('recent_searches',
        where: 'LOWER(query) = LOWER(?)', whereArgs: [query]);
  }

  Future<void> clearRecentSearches() async {
    final db = await database;
    await db.delete('recent_searches');
  }

  /// Check if a file with same name and size already exists
  Future<bool> isDuplicate(String originalName, int fileSizeBytes) async {
    final db = await database;
    final result = await db.query(
      'documents',
      where: 'original_name = ? AND file_size_bytes = ?',
      whereArgs: [originalName, fileSizeBytes],
    );
    return result.isNotEmpty;
  }

  /// Export all metadata as JSON
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    final folders = await db.query('folders');
    final documents = await db.query('documents');
    return {
      'app': 'Neatly',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'folders': folders,
      'documents': documents,
    };
  }
}
