// // import 'package:flutter/material.dart';
// // import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// //
// // class FavoritePageGrid extends StatelessWidget {
// //   final List<int> favorites;
// //   final Function(int) onTapPage;
// //
// //   const FavoritePageGrid({
// //     Key? key,
// //     required this.favorites,
// //     required this.onTapPage,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MasonryGridView.count(
// //       padding: const EdgeInsets.all(12),
// //       crossAxisCount: 2,
// //       mainAxisSpacing: 12,
// //       crossAxisSpacing: 12,
// //       itemCount: favorites.length,
// //       itemBuilder: (context, index) {
// //         final page = favorites[index];
// //         return GestureDetector(
// //           onTap: () => onTapPage(page),
// //           child: Container(
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: Colors.blueAccent.shade100,
// //               borderRadius: BorderRadius.circular(16),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black26,
// //                   blurRadius: 6,
// //                   offset: Offset(2, 2),
// //                 )
// //               ],
// //             ),
// //             child: Center(
// //               child: Text(
// //                 'Page #$page',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// // favorite_pages_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:sakoon_shar/HomePage.dart';
//
// import 'Utils.dart';
// import 'main.dart';
//
// class FavoritePagesScreen extends StatelessWidget {
//   final List<int> favoritePages;
//
//   const FavoritePagesScreen({
//     Key? key,
//     required this.favoritePages,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Favorite Pages"),
//       ),
//       body: MasonryGridView.count(
//         padding: const EdgeInsets.all(12),
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         itemCount: favoritePages.length,
//         itemBuilder: (context, index) {
//           final page = favoritePages[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => MyHomePage(
//                       title: 'aa',
//                       index: page+7,
//                       size1: Utils.updateFontSize,
//                     )
//                 ),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.indigoAccent,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 6,
//                     offset: Offset(2, 3),
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Text(
//                   "Page #$page",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sakoon_shar/FavoritePageStorage.dart';
import 'package:sakoon_shar/HomePage.dart';
import 'package:sakoon_shar/Utils.dart';

import 'main.dart';

class FavoritePagesScreen extends StatefulWidget {
  const FavoritePagesScreen({Key? key}) : super(key: key);

  @override
  _FavoritePagesScreenState createState() => _FavoritePagesScreenState();
}

class _FavoritePagesScreenState extends State<FavoritePagesScreen> {
  late Future<List<int>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = FavoritePageStorage.getFavorites();
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = FavoritePageStorage.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface), // change arrow color
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshFavorites,
          ),
        ],
        title: Text(
          'نښه شوې پاڼې',
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
      //   title: const Text("Favorite Pages"),
      //
      // ),
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: FutureBuilder<List<int>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading favorites'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No favorite pages yet'));
            }

            final favoritePages = snapshot.data!;
            return MasonryGridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: favoritePages.length,
              itemBuilder: (context, index) {
                final page = favoritePages[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(
                          index: page + 7,
                          size1: Utils.updateFontSize,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xDFC5B298),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Page\n",
                              style: TextStyle(
                                fontSize: 16,  // Smaller size for "Page"
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: "$page",  // Page number
                              style: TextStyle(
                                fontSize: 28,  // Larger size for the number
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // child: Center(
                    //   child: Text(
                    //     "Page\n$page",
                    //     style: TextStyle(
                    //       fontSize: 20,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}