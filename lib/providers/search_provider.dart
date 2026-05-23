import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';
import '../domain/models/document.dart';
import 'database_provider.dart';

/// Search state.
class SearchState {
  final String query;
  final List<DocumentModel> results;
  final List<String> recentSearches;
  final bool isSearching;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.isSearching = false,
  });

  SearchState copyWith({
    String? query,
    List<DocumentModel>? results,
    List<String>? recentSearches,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final AppDatabase _db;

  SearchNotifier(this._db) : super(const SearchState()) {
    loadRecentSearches();
  }

  Future<void> loadRecentSearches() async {
    final recent = await _db.getRecentSearches();
    state = state.copyWith(recentSearches: recent);
  }

  Future<void> search(String query) async {
    state = state.copyWith(query: query, isSearching: true);
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    try {
      final results = await _db.searchDocuments(query);
      state = state.copyWith(results: results, isSearching: false);
    } catch (e) {
      state = state.copyWith(results: [], isSearching: false);
    }
  }

  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    await _db.addRecentSearch(query);
    await loadRecentSearches();
  }

  Future<void> deleteRecentSearch(String query) async {
    await _db.deleteRecentSearch(query);
    await loadRecentSearches();
  }

  Future<void> clearRecentSearches() async {
    await _db.clearRecentSearches();
    state = state.copyWith(recentSearches: []);
  }

  void clearResults() {
    state = state.copyWith(query: '', results: []);
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final db = ref.watch(databaseProvider);
  return SearchNotifier(db);
});
