import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants.dart';
import '../data/database/app_database.dart';
import '../data/services/file_service.dart';
import '../data/services/document_parser_service.dart';
import '../domain/models/document.dart';
import 'database_provider.dart';
import 'ai_queue_provider.dart';
import 'settings_provider.dart';

/// Notifier for document operations.
class DocumentsNotifier extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  final AppDatabase _db;
  final Ref _ref;

  DocumentsNotifier(this._db, this._ref)
      : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
      final docs = await _db.getAllDocuments();
      state = AsyncValue.data(docs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pickAndUploadFiles({bool multiple = false}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'pptx'],
        allowMultiple: multiple,
      );

      if (result == null || result.files.isEmpty) return;

      for (final file in result.files) {
        if (file.path == null) continue;
        await _uploadFile(file.path!, file.name, file.size);
      }
    } catch (e) {
      // Silently handle file picker errors
    }
  }

  Future<void> uploadFromPath(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;
    final stat = await file.stat();
    final name = filePath.split(Platform.pathSeparator).last;
    await _uploadFile(filePath, name, stat.size);
  }

  Future<void> _uploadFile(
      String sourcePath, String originalName, int sizeBytes) async {
    // 1. Determine file type
    final fileType = FileService.getFileType(originalName);
    if (!AppConstants.supportedExtensions.contains(fileType)) return;

    // 2. Optional duplicate guard based on settings
    final isDuplicate = await _db.isDuplicate(originalName, sizeBytes);
    final autoDeleteDuplicates =
        _ref.read(settingsProvider).autoDeleteDuplicates;
    if (isDuplicate && autoDeleteDuplicates) return;

    // 3. Copy to app storage
    final destPath = await FileService.copyFileToAppStorage(sourcePath);

    // 4. Get page count if PDF
    int? pageCount;
    if (fileType == 'pdf') {
      pageCount =
          await DocumentParserService.getPageCount(destPath, fileType);
    }

    // 5. Create document record
    final now = DateTime.now();
    final doc = DocumentModel(
      originalName: originalName,
      displayName: originalName,
      filePath: destPath,
      fileType: fileType,
      fileSizeBytes: sizeBytes,
      pageCount: pageCount,
      aiStatus: 'pending',
      uploadedAt: now,
      updatedAt: now,
    );

    final id = await _db.insertDocument(doc);
    await loadDocuments();

    // 6. Enqueue for AI processing
    _ref.read(aiQueueProvider.notifier).enqueue(id);
  }

  Future<void> deleteDocument(int id) async {
    final doc = await _db.getDocumentById(id);
    if (doc != null) {
      await FileService.deleteFile(doc.filePath);
    }
    await _db.deleteDocument(id);
    await loadDocuments();
  }

  Future<void> toggleFavourite(int id) async {
    final doc = await _db.getDocumentById(id);
    if (doc != null) {
      await _db.toggleFavourite(id, !doc.isFavourite);
      await loadDocuments();
    }
  }

  Future<void> moveToFolder(int docId, int? folderId) async {
    final doc = await _db.getDocumentById(docId);
    if (doc != null) {
      await _db.updateDocument(doc.copyWith(
        folderId: folderId,
        updatedAt: DateTime.now(),
      ));
      await loadDocuments();
    }
  }

  Future<void> renameDocument(int id, String newName) async {
    final doc = await _db.getDocumentById(id);
    if (doc != null) {
      await _db.updateDocument(doc.copyWith(
        displayName: newName,
        updatedAt: DateTime.now(),
      ));
      await loadDocuments();
    }
  }

  Future<void> retryAiProcessing(int id) async {
    await _db.updateAiStatus(id, 'pending');
    await loadDocuments();
    _ref.read(aiQueueProvider.notifier).enqueue(id);
  }

  Future<int> getDocumentCount() => _db.getDocumentCount();
  Future<int> getThisWeekCount() => _db.getThisWeekDocumentCount();
}

final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, AsyncValue<List<DocumentModel>>>(
        (ref) {
  final db = ref.watch(databaseProvider);
  return DocumentsNotifier(db, ref);
});

/// Provider for documents in a specific folder.
final folderDocumentsProvider = FutureProvider.family<List<DocumentModel>, int>(
    (ref, folderId) async {
  final db = ref.watch(databaseProvider);
  return db.getDocumentsByFolder(folderId);
});

/// Provider for a single document by ID.
final documentByIdProvider =
    FutureProvider.family<DocumentModel?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.getDocumentById(id);
});
