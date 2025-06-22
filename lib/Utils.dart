import 'dart:collection';
import 'dart:developer';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class Utils{
  static final indexKey = "pageIndex", fontSize1 = "fontSize1", fontSize2 = "fontSize2", fontSize3 = "fontSize3";
  static final ip = "ip", footnoteExpansion="footnoteExpansion";
  static late LinkedHashMap<String, String> bookPages;

  // static Map<String, String> splitTextIntoPages(String bookText) {
  //   // Split the text at the "---" separator
  //   List<String> pages = bookText.split('---').map((e) => e.trim()).toList();
  //
  //   // Create a HashMap to store the result
  //   HashMap<String, String> pageMap = HashMap();
  //
  //   // Add the first 8 pages with keys A, B, C, ...
  //   const List<String> firstKeys = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  //   for (int i = 0; i < pages.length; i++) {
  //     if (i < firstKeys.length) {
  //       pageMap[firstKeys[i]] = pages[i];
  //     } else {
  //       pageMap[(i - firstKeys.length + 1).toString()] = pages[i];
  //     }
  //
  //   }
  //   // Get all keys
  //   Iterable<String> keys = pageMap.keys;
  //
  //   for (var key in keys) {
  //     log('page number: $key');
  //   }
  //   return pageMap;
  // }

  static LinkedHashMap<String, String> splitTextIntoPages(String bookText) {
    // Split the text at the "---" separator
    List<String> pages = bookText.split('---').map((e) => e.trim()).toList();

    // Create a LinkedHashMap to maintain insertion order
    LinkedHashMap<String, String> pageMap = LinkedHashMap();

    // Add the first 8 pages with keys A, B, C, ...
    const List<String> firstKeys = ['الف', 'ب', 'ت', 'ث', 'ح', 'خ', 'ق', 'ن'];
    for (int i = 0; i < pages.length; i++) {
      if (i < firstKeys.length) {
        pageMap[firstKeys[i]] = pages[i];
      } else {
        pageMap[(i - firstKeys.length + 1).toString()] = pages[i];
      }
    }
      // Get all keys
      Iterable<String> keys = pageMap.keys;

      // for (var key in keys) {
      //   log('page number: $key');
      // }
    return pageMap;
  }


  static List<Map<String, dynamic>> extractHeadings(Map<String, String> pages) {
    List<Map<String, dynamic>> _headings = [];
    pages.forEach((key, value) {
      // log('Key: $key, Value: $value');
      final lines = value.split('\n');

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.startsWith('#')) {
          final level = line.indexOf(' ') - line.indexOf('#');
          final title = line.replaceFirst(RegExp(r'#+\s*'), '');
          // log('Title:$title');
          // log('Level:$level');
          // log('index:$key');
          _headings.add({
            'title': title,
            'level': level,
            'index': key,
          });
        }
      }
    });

    return _headings;
  }


  // Method to return the ListView widget
  Widget buildTextList(BuildContext context, List<Map<String, dynamic>> items) {

    // Return the ListView
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontFamily: 'mitra_bold',
                    fontSize: 16.0,
                  ),
                ),
                // Dots and Page Number
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate space for dots dynamically
                      double availableWidth = constraints.maxWidth;

                      // Measure text widths for title and page number
                      double pageWidth = _getTextWidth(context, item['index'].toString());
                      double dotWidth = _getTextWidth(context, '.');
                      int numberOfDots = ((availableWidth - pageWidth) / dotWidth).floor();

                      // Generate dots
                      String dots = List.filled(numberOfDots > 0 ? numberOfDots : 0, '.').join();

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dots,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'mitra_regular', // Monospace ensures equal dot width
                              ),
                              softWrap: false,
                            ),
                          ),
                          Text(
                            item['index'].toString(),
                            style: const TextStyle(
                              fontFamily: 'mitra_regular',
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(index: int.parse(item['index'])+7, size1: Utils.updateFontSize,)),
            );

            // Handle click
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('redirected to ${item['title']} (Page ${item['index']})')),
            );
          },
        );
      },
    );
  }




  // Utility to measure text width
  double _getTextWidth(BuildContext context, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 16.0), // Match the font size here
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }



  // Method to save data
  static void saveInt(String key, int data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, data);
    print("Data Saved! : $data");
  }
  static void saveDouble(String key, double data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, data);
    updateFontSize = data;
    print("Data Saved! : $data");
  }
  static void saveBool(String key, bool data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, data);
    print("Purchase Saved! : $data");
  }
  // Method to load data
  static Future<int> loadInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }
  static Future<double> loadDouble(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double result = prefs.getDouble(key) ?? 14;
    updateFontSize = result;
    return result;
  }
  static Future<bool> loadBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static double updateFontSize = 0;
}