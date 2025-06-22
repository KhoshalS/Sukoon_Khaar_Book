import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FavoritePageStorage {
  static const _fileName = 'page.txt';

  // Get app's local directory path
  static Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  // Get file reference
  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  /// ✅ Add a new favorite page (append to file)
  static Future<void> addFavorite(int page) async {
    final file = await _localFile;

    // Prevent duplicate entries
    final existing = await getFavorites();
    if (!existing.contains(page)) {
      await file.writeAsString('$page\n', mode: FileMode.append);
      print("favoriteAdded: $page");
    }else{
      print("favorite is dupblicated: $page");
    }
  }

  /// ✅ Get all favorite pages as a list of ints
  static Future<List<int>> getFavorites() async {
    final file = await _localFile;

    if (!await file.exists()) return [];

    final lines = await file.readAsLines();
    List<int> result = lines.map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet() // remove duplicates
        .toList()
      ..sort();
    print("Favorite result are: ");
    print(result);
    return result;
  }

  /// ❌ Optional: remove a page from favorites
  static Future<void> removeFavorite(int page) async {
    final favorites = await getFavorites();
    favorites.remove(page);

    final file = await _localFile;
    final content = favorites.map((e) => '$e').join('\n');
    await file.writeAsString(content);
  }

  /// ❌ Optional: clear all favorites
  static Future<void> clearFavorites() async {
    final file = await _localFile;
    await file.writeAsString('');
  }
}
