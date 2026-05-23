import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';
import '../data/services/ai_service.dart';
import '../data/services/document_parser_service.dart';
import '../domain/models/document.dart';
import 'database_provider.dart';
import 'folders_provider.dart';
import 'documents_provider.dart';

/// State for the AI processing queue.
class AiQueueState {
  static const _unset = Object();

  final List<int> queue;
  final int? currentlyProcessing;
  final bool isProcessing;
  final String? lastError;

  const AiQueueState({
    this.queue = const [],
    this.currentlyProcessing,
    this.isProcessing = false,
    this.lastError,
  });

  int get pendingCount => queue.length + (isProcessing ? 1 : 0);

  AiQueueState copyWith({
    List<int>? queue,
    Object? currentlyProcessing = _unset,
    bool? isProcessing,
    Object? lastError = _unset,
  }) {
    return AiQueueState(
      queue: queue ?? this.queue,
      currentlyProcessing: currentlyProcessing == _unset
          ? this.currentlyProcessing
          : currentlyProcessing as int?,
      isProcessing: isProcessing ?? this.isProcessing,
      lastError:
          lastError == _unset ? this.lastError : lastError as String?,
    );
  }
}

/// Manages AI processing queue — processes documents one at a time.
class AiQueueNotifier extends StateNotifier<AiQueueState> {
  final AppDatabase _db;
  final Ref _ref;

  AiQueueNotifier(this._db, this._ref) : super(const AiQueueState()) {
    _loadPendingDocuments();
  }

  Future<void> _loadPendingDocuments() async {
    // Check for any pending documents on startup
    final pending = await _db.getPendingDocuments();
    if (pending.isNotEmpty) {
      final ids = pending.map((d) => d.id!).toList();
      state = state.copyWith(queue: ids);
      _processNext();
    }
  }

  void enqueue(int documentId) {
    if (state.queue.contains(documentId) ||
        state.currentlyProcessing == documentId) return;
    state = state.copyWith(
      queue: [...state.queue, documentId],
    );
    if (!state.isProcessing) {
      _processNext();
    }
  }

  Future<void> _processNext() async {
    if (state.queue.isEmpty) {
      state = state.copyWith(
        isProcessing: false,
        currentlyProcessing: null,
      );
      return;
    }

    final docId = state.queue.first;
    state = state.copyWith(
      queue: state.queue.sublist(1),
      currentlyProcessing: docId,
      isProcessing: true,
      lastError: null,
    );

    try {
      await _processDocument(docId);
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }

    state = state.copyWith(currentlyProcessing: null);

    // Process next in queue
    _processNext();
  }

  Future<void> _processDocument(int docId) async {
    try {
      // 1. Get document
      final doc = await _db.getDocumentById(docId);
      if (doc == null) return;

      // 2. Update status to processing
      await _db.updateAiStatus(docId, 'processing');

      // 3. Extract text
      final text = await DocumentParserService.extractText(
          doc.filePath, doc.fileType);

      // 4. Call Claude AI
      final result = await AiService.classifyDocument(
        extractedText: text,
        originalFilename: doc.originalName,
        fileType: doc.fileType,
      );

      // 5. Find or create folder
      final foldersNotifier = _ref.read(foldersProvider.notifier);
      final folder = await foldersNotifier.getOrCreateFolder(result.folderName);

      // 6. Update document with AI results
      await _db.updateDocumentAiResult(
        id: docId,
        aiName: result.suggestedName,
        aiSummary: result.summary,
        aiTags: result.tags,
        folderId: folder?.id,
      );

      // 7. Index in FTS5
      await _db.indexDocument(
        docId: docId,
        displayName: result.suggestedName,
        aiSummary: result.summary,
        fullTextContent: text,
        aiTags: result.tags,
      );

      // 8. Reload folders and documents
      await foldersNotifier.loadFolders();
    } catch (e) {
      // Mark as failed
      await _db.updateAiStatus(docId, 'failed');
      rethrow;
    } finally {
      await _ref.read(documentsProvider.notifier).loadDocuments();
    }
  }
}

final aiQueueProvider =
    StateNotifierProvider<AiQueueNotifier, AiQueueState>((ref) {
  final db = ref.watch(databaseProvider);
  return AiQueueNotifier(db, ref);
});
