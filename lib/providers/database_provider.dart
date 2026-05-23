import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';

/// Provider for the app database singleton.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});
