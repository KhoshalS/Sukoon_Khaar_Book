import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Utils.dart';

class TableOfContent extends StatelessWidget {
  Future<LinkedHashMap<String, String>> loadMarkdownFile() async {
    String fullBook = await rootBundle.loadString('assets/sakoon.md');
    Utils.bookPages = Utils.splitTextIntoPages(fullBook);
    Utils.extractHeadings(Utils.bookPages);

    return Utils.bookPages;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface), // change arrow color
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: false,
        title: Text(
          'لړلیک',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // appBar: AppBar(
      //   title: Expanded(child: Text('لړلیک', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.bold),)),
      //   backgroundColor: Theme.of(context).colorScheme.onPrimary,
      // ),
      // body:Directionality(
      //   textDirection: TextDirection.rtl, // Right-to-left alignment for Pashto
      //   //   child:  Markdown(
      //   //     data: snapshot.data ?? '',
      //   //     styleSheet: MarkdownStyleSheet(
      //   //       p: TextStyle(
      //   //         fontFamily: 'mitra_regular', // Use the custom font
      //   //         fontSize: 14,
      //   //       ),
      //   //       h1: TextStyle(
      //   //         fontFamily: 'mitra_bold', // Use bold font for headers
      //   //         fontSize: 16,
      //   //         fontWeight: FontWeight.bold,
      //   //       ),
      //   //       listBullet: TextStyle(
      //   //         fontFamily: 'mitra_regular', // Font for list bullets
      //   //         fontSize: 18,
      //   //       ),
      //   //     ),
      //   // )
      //   child: Utils().buildTextList(context, Utils.extractHeadings(snapshot.data??Utils.bookPages) ),
      // ),
      //   //Last Body
        body: FutureBuilder<Map<String, String>>(

          future: loadMarkdownFile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Directionality(
                textDirection: TextDirection.rtl, // Right-to-left alignment for Pashto
                child: Utils().buildTextList(context, Utils.extractHeadings(snapshot.data??Utils.bookPages) ),
              );
            }
          },
        ),
      );
  }
}
