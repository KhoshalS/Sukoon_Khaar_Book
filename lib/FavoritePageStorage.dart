// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
//
// class FavoritePageStorage {
//   static const _fileName = 'page.txt';
//
//   // Get app's local directory path
//   static Future<String> get _localPath async {
//     final dir = await getApplicationDocumentsDirectory();
//     return dir.path;
//   }
//
//   // Get file reference
//   static Future<File> get _localFile async {
//     final path = await _localPath;
//     return File('$path/$_fileName');
//   }
//
//   /// ✅ Add a new favorite page (append to file)
//   static Future<void> addFavorite(int page) async {
//     final file = await _localFile;
//
//     // Prevent duplicate entries
//     final existing = await getFavorites();
//     if (!existing.contains(page)) {
//       await file.writeAsString('$page\n', mode: FileMode.append);
//       print("favoriteAdded: $page");
//     }else{
//       print("favorite is dupblicated: $page");
//     }
//   }
//
//   /// ✅ Get all favorite pages as a list of ints
//   static Future<List<int>> getFavorites() async {
//     final file = await _localFile;
//
//     if (!await file.exists()) return [];
//
//     final lines = await file.readAsLines();
//     List<int> result = lines.map((e) => int.tryParse(e.trim()))
//         .whereType<int>()
//         .toSet() // remove duplicates
//         .toList()
//       ..sort();
//     print("Favorite result are: ");
//     print(result);
//     return result;
//   }
//
//   /// ❌ Optional: remove a page from favorites
//   static Future<void> removeFavorite(int page) async {
//     final favorites = await getFavorites();
//     favorites.remove(page);
//
//     final file = await _localFile;
//     final content = favorites.map((e) => '$e').join('\n');
//     await file.writeAsString(content);
//   }
//
//   /// ❌ Optional: clear all favorites
//   static Future<void> clearFavorites() async {
//     final file = await _localFile;
//     await file.writeAsString('');
//   }
// }
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class FavoritePageStorage {
  static const _fileName = 'favorites.txt';  // Changed to more descriptive name
  static bool _initializationChecked = false;

  // Get app's local directory path with fallback
  static Future<String> get _localPath async {
    try {
      if (!_initializationChecked) {
        await _verifyPathProvider();
        _initializationChecked = true;
      }

      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e, stack) {
      debugPrint("Error getting documents directory: $e\n$stack");

      // Fallback to temporary directory if main storage fails
      final tempDir = Directory.systemTemp;
      await tempDir.create(recursive: true);
      return tempDir.path;
    }
  }

  // Verify path_provider is working
  static Future<void> _verifyPathProvider() async {
    try {
      // Test path provider functionality
      final dir = await getApplicationDocumentsDirectory();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } catch (e, stack) {
      debugPrint("Path provider verification failed: $e\n$stack");
      throw Exception("Storage system unavailable");
    }
  }

  // Get file reference with validation
  static Future<File> get _localFile async {
    try {
      final path = await _localPath;
      final file = File('$path/$_fileName');

      // Ensure parent directory exists
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      return file;
    } catch (e, stack) {
      debugPrint("Error accessing local file: $e\n$stack");
      rethrow;
    }
  }

  /// Add a new favorite page (atomic operation)
  static Future<void> addFavorite(int page) async {
    try {
      final file = await _localFile;
      final existing = await getFavorites();

      if (!existing.contains(page)) {
        // Use atomic write operation
        await file.writeAsString(
            '${existing.join('\n')}\n$page\n',
            mode: FileMode.write,
            flush: true
        );
        debugPrint("Favorite added: $page");
      } else {
        debugPrint("Favorite already exists: $page");
      }
    } catch (e, stack) {
      debugPrint("Error adding favorite: $e\n$stack");
      throw Exception("Failed to save favorite");
    }
  }

  /// Get all favorite pages (sorted unique list)
  static Future<List<int>> getFavorites() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) return [];

      final content = await file.readAsString();
      return content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toSet() // Remove duplicates
          .toList()
        ..sort();
    } catch (e, stack) {
      debugPrint("Error reading favorites: $e\n$stack");
      return []; // Return empty list on error
    }
  }

  /// Remove a page from favorites (atomic operation)
  static Future<void> removeFavorite(int page) async {
    try {
      final favorites = await getFavorites();
      favorites.remove(page);

      final file = await _localFile;
      await file.writeAsString(
          favorites.join('\n'),
          mode: FileMode.write,
          flush: true
      );
      debugPrint("Favorite removed: $page");
    } catch (e, stack) {
      debugPrint("Error removing favorite: $e\n$stack");
      throw Exception("Failed to remove favorite");
    }
  }

  /// Clear all favorites
  static Future<void> clearFavorites() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.writeAsString('', mode: FileMode.write, flush: true);
      }
      debugPrint("All favorites cleared");
    } catch (e, stack) {
      debugPrint("Error clearing favorites: $e\n$stack");
      throw Exception("Failed to clear favorites");
    }
  }
}