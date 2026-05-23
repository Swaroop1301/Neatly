import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/constants.dart';

/// File operations: copy, delete, storage management.
class FileService {
  /// Get the app's document storage directory.
  static Future<Directory> getStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final storageDir = Directory(p.join(appDir.path, AppConstants.filesSubdir));
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    return storageDir;
  }

  /// Copy a file to app internal storage.
  /// Returns the new file path.
  static Future<String> copyFileToAppStorage(String sourcePath) async {
    final storageDir = await getStorageDirectory();
    final sourceFile = File(sourcePath);
    final fileName = p.basename(sourcePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitized = fileName
        .replaceAll(RegExp(r'[<>:"|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    final destPath = p.join(storageDir.path, '${timestamp}_$sanitized');
    
    await sourceFile.copy(destPath);
    return destPath;
  }

  /// Delete a file from storage.
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get formatted file size.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get the file type from extension.
  static String getFileType(String fileName) {
    final ext = p.extension(fileName).toLowerCase().replaceFirst('.', '');
    switch (ext) {
      case 'pdf':
        return 'pdf';
      case 'docx':
      case 'doc':
        return 'docx';
      case 'pptx':
      case 'ppt':
        return 'pptx';
      default:
        return ext;
    }
  }

  /// Get total storage used by the app.
  static Future<int> getTotalStorageUsed() async {
    final storageDir = await getStorageDirectory();
    int total = 0;
    if (await storageDir.exists()) {
      await for (final entity in storageDir.list()) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    }
    return total;
  }
}
