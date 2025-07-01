import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:sakoon_shar/CustomColors.dart';
import 'package:sakoon_shar/FavoritePageStorage.dart';
import 'package:sakoon_shar/Utils.dart';
import 'package:sakoon_shar/themes.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:markdown/markdown.dart' as md;

import 'HomePage.dart';
import 'IAPScreen.dart';
import 'ThemeProvider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await InAppPurchase.instance.isAvailable();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    ChangeNotifierProvider(
      create: (context) => themeProvider,
      child: const MyApp(),
    ),
  );
}
// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: const MyApp(),
//     ),
//   );
//   // runApp(const MyApp());
// }

class MyApp extends StatelessWidget {

  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // final InAppPurchase _iap = InAppPurchase.instance;
    return MaterialApp(
      theme: getLightTheme(), // Using the light theme
      darkTheme: getDarkTheme(), // Using the dark theme
      themeMode: themeProvider.themeMode, // Using the provider's mode
      // theme: ThemeData.light(),
      // darkTheme: ThemeData.dark(),
      // themeMode: themeProvider.themeMode,
      title: 'د سکون ښار',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
      home: Directionality(
        // Set text direction to RTL
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget with WidgetsBindingObserver{
  final int index;
  final double size1;
  const MyHomePage({super.key, required this.index, required this.size1});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

late List<Map<String, dynamic>> listOfHeader;
final TextEditingController _pageNumberController = TextEditingController();

class _MyHomePageState extends State<MyHomePage> {
  int currentPageNumber = 0;
  int l = 25;
  double textSizeDefault = 14.0;
  // double size1 = 14, size2 = 16, size3 = 18;
  late PageController _pageController;
  ValueNotifier<Map<String, double>> fontSizes = ValueNotifier({
    'size1': Utils.updateFontSize,
  });
  ValueNotifier<Map<String, bool>> ip = ValueNotifier({
    'ip': false,
  });
  ValueNotifier<Map<String, bool>> isDark = ValueNotifier({
    'isDark': false,
  });
  final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);
  Future<void> loadFootNoteExpansion() async {
    final isExpand = await Utils.loadBool(Utils.footnoteExpansion);
    isExpanded.value = isExpand;
    print("Expand loaded: $isExpand");
  }
  // ValueNotifier<Map<int, bool>> favoritePages = ValueNotifier({});
  final ValueNotifier<Map<String, dynamic>> pageState = ValueNotifier({
    'currentPage': 0,
    'favorites': <int, bool>{},
  });
  Future<void> loadFavorite() async {
    final favorites = await FavoritePageStorage.getFavorites();
    pageState.value = {
      'currentPage': widget.index,
      'favorites': {for (var p in favorites) p: true},
    };
    print("Favorite loaded.");
  }

  Future<void> loadIP() async {
    final ipx = await Utils.loadBool(Utils.ip);
    ip.value = {
      'ip': ipx,
    };
    print("ip loaded.");
  }

  loadTheme(){
    isDark.value = {
      'isDark':ThemeProvider.isDark,
    };
    print("X_"+ThemeProvider.isDark.toString());
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
    // _enableSecureScreen();
    _pageController = PageController(initialPage: 0);
    loadFavorite();
    loadFootNoteExpansion();
    //loadIP();
    loadIP().then((_) {
      // Show purchase dialog if initial page is at demo limit
      if (!ip.value["ip"]! && widget.index >= l - 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showPurchaseBottomSheet(context);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 50), () {
        try {
          _pageController.jumpToPage(widget.index);
          print("Scroll happened");
        } catch (e) {
          print("Exception in delayed scroll: $e");
          // Retry after a longer delay if needed
          Future.delayed(Duration(milliseconds: 100), () {
            try {
              _pageController.jumpToPage(widget.index);
              print("Retry scroll happened");
            } catch (e) {
              Future.delayed(Duration(milliseconds: 500), () {
                try {
                  _pageController.jumpToPage(widget.index);
                  print("Retry scroll happened");
                } catch (e) {
                  Future.delayed(Duration(milliseconds: 1200), () {
                    try {
                      _pageController.jumpToPage(widget.index);
                      print("Retry scroll happened");
                    } catch (e) {
                      print("Retry failed too: $e");
                    }
                  });
                }
              });
            }
          });
        }
      });
    });

    // try {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Future.delayed(Duration(milliseconds: 2), () {
    //       _pageController
    //           .jumpToPage(widget.index); // Jump to the 3rd page (index 2)
    //       print("Scroll happend");
    //     });
    //   });
    // } catch (e) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Future.delayed(Duration(milliseconds: 200), () {
    //       _pageController
    //           .jumpToPage(widget.index); // Jump to the 3rd page (index 2)
    //       print("Scroll happend");
    //     });
    //   });
    // }
  }

  final ValueNotifier<bool> _showGoToContainer = ValueNotifier(false);
  final ValueNotifier<bool> _showToolbar = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _showZoomToolbar = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isDark = ValueNotifier<bool>(false);


  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    // final abc = Theme.of(context).extension<CustomColors>()!.abc;  // ✅
    // final themeProvider = Provider.of<ThemeProvider>(context);
    // bool isDarkMode = ThemeProvider.isDark;
    // print("X_$isDarkMode");

    Future<LinkedHashMap<String, String>> loadMarkdownFile() async {
      String fullBook = await rootBundle.loadString('assets/sakoon.md');
      Utils.bookPages = Utils.splitTextIntoPages(fullBook);
      return Utils.bookPages;
    }
    bool _isExpanded = false;

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Theme.of(context).colorScheme.onSecondary, // Or any custom color
    //   statusBarIconBrightness: Brightness.dark, // For dark icons on light background
    //   statusBarBrightness: Brightness.light, // For iOS (status bar text color)
    // ));
    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface), // change arrow color
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        toolbarHeight: 0,
      ),
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.onSecondary,
      // ),
      // appBar: AppBar(
      //   title: Text('Status Bar Example'),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   systemOverlayStyle: SystemUiOverlayStyle(
      //     statusBarColor: Colors.white, // Ensures AppBar doesn't override it
      //     statusBarIconBrightness: Brightness.dark,
      //     statusBarBrightness: Brightness.light,
      //   ),
      // ),

      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          loadMarkdownFile(), // Your actual data future
          Future.delayed(Duration(milliseconds: 50)), // Minimum spinner time
        ]),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SafeArea(
              child: Column(
                children: [

                  ValueListenableBuilder<Map<String, bool>>(
                    valueListenable: ip,
                    builder: (context, ipx, _) {
                      return Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: pageChanged,
                            itemCount: ip.value["ip"] == true
                                ? Utils.bookPages.length
                                : l,
                            itemBuilder: (context, index) {
                              currentPageNumber = index;
                              String title =
                                  Utils.bookPages.keys.elementAt(index);
                              String content = removeFootnotes(Utils.bookPages.values.elementAt(index));

                              // Combine all footnote values into one string
                              final combinedFootnotes = extractFootnotes(Utils.bookPages.values.elementAt(index)).entries
                                  .map((entry) => '${entry.key}. ${entry.value.replaceAll(":", "")}')
                                  .join('\n');
                              return Container(
                                color: Theme.of(context).colorScheme.onSecondary,
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).shadowColor.withValues(alpha: 0.5), //Colors.grey.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(4.0),
                                        color: Colors.blueGrey,
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'mitra_bold',
                                            color: Colors.white,
                                            // color: abc,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          // padding: EdgeInsets.all(10.0),
                                          padding: EdgeInsets.only(left: 1.0, right: 1.0, top: 0.0, bottom: 0.0),
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: ValueListenableBuilder<
                                                Map<String, double>>(
                                              valueListenable: fontSizes,
                                              builder: (_, sizes, __) {

                                                Utils.saveDouble(Utils.fontSize1,
                                                    sizes['size1']!);
                                                return Markdown(
                                                  data: content,
                                                  // builders: {
                                                  //   'a': _NoIconLinkBuilder(),
                                                  // },
                                                  styleSheet: MarkdownStyleSheet(
                                                    // a: TextStyle(
                                                    //   decoration: TextDecoration.none,
                                                    //   color: Colors.blue, // Same as footnote definitions for consistency
                                                    // ),
                                                    // a: TextStyle(
                                                    //   decoration: TextDecoration
                                                    //       .none, // Remove underline globally
                                                    // ),
                                                    p: TextStyle(
                                                      fontFamily: 'mitra_regular',
                                                      fontSize: sizes['size1'],
                                                    ),
                                                    h1: TextStyle(
                                                      fontFamily: 'mitra_bold',
                                                      fontSize: sizes['size1']! + 2,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    h6: TextStyle(
                                                      fontFamily: 'mitra_bold',
                                                      fontSize:
                                                          sizes['size1']! + 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    listBullet: TextStyle(
                                                      fontFamily: 'mitra_regular',
                                                      fontSize: sizes['size1']! + 4,
                                                    ),
                                                  ),
                                                  // onTapLink: (text, href, title) {
                                                  //   // Handle footnote/link tapping if needed
                                                  //   if (href?.startsWith('#') ??
                                                  //       false) {
                                                  //
                                                  //     // Footnote handling logic
                                                  //   }
                                                  // },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Text(combinedFootnotes,style: TextStyle(fontSize: 12),)

                                ValueListenableBuilder<bool>(
                                valueListenable: isExpanded,
                                builder: (context, expanded, _) {
                                  void toggleExpanded() {
                                    bool e = !expanded;
                                    Utils.saveBool(Utils.footnoteExpansion, e);
                                    print("Expanded saved as: $e");
                                    isExpanded.value = e;
                                  }
                                return
                                GestureDetector(
                                  onTap: toggleExpanded,//() => isExpanded.value = !expanded ,
                                child: Card(
                                elevation: 5,
                                color:Theme.of(context).colorScheme.onSecondary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                                child: expanded
                                    ? _buildExpandedView(combinedFootnotes)
                                    : _buildCollapsedView(),
                                // child: _isExpanded ? _buildExpandedView(combinedFootnotes) : _buildCollapsedView(),
                                ),
                                ),
                                );
                                })

                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: _showZoomToolbar,
                    builder: (context, showZoom, _) {
                      if (!showZoom) return SizedBox.shrink();
                      return SizedBox(
                        height: 50,
                        child: Container(
                          color: Colors.grey[900],
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              /// Wrap Slider and label in another ValueListenableBuilder
                              ValueListenableBuilder<Map<String, double>>(
                                valueListenable: fontSizes,
                                builder: (context, sizes, _) {
                                  return Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          "${(sizes['size1']! * (100 / 14)).round()}%",
                                          // "Zoom: ${(sizes['size1']!.toInt()*(100/14))}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Slider(
                                            min: 8,
                                            max: 28,
                                            value: sizes['size1']!,
                                            onChanged: (value) {
                                              fontSizes.value = {'size1': value};
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  fontSizes.value = {
                                    'size1':textSizeDefault,
                                  };
                                  // Handle zoom level click here
                                  print(
                                      "Zoom level clicked: ${fontSizes.value['size1']!.toInt()}");
                                },
                                child: Text(
                                  "100%",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () => _showZoomToolbar.value = false,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: _showToolbar,
                    builder: (context, showToolbar, _) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: showToolbar ? null : 30, // Show only icon row when collapsed
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!showToolbar)
                              GestureDetector(
                                onTap: () => _showToolbar.value = true,
                                child: Container(
                                  color: Colors.black,
                                  height: 30,
                                  alignment: Alignment.center,
                                  child: Icon(Icons.keyboard_arrow_up, color: Colors.white),
                                ),
                              ),
                            if (showToolbar)
                              Container(
                                color: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 1),
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: _showGoToContainer,
                                  builder: (context, showContainer, _) {
                                    return Column(
                                      children: [
                                        if (showContainer) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 35,
                                                  width: 140,
                                                  child: TextField(
                                                    controller: _pageNumberController,

                                                    decoration: InputDecoration(
                                                      hintText: 'Page Number',
                                                      filled: true,
                                                      fillColor: Colors.grey,
                                                      // border: OutlineInputBorder(),
                                                      contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(6), // 👈 round corners here
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(6),
                                                        borderSide: BorderSide(color: Colors.grey), // optional
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(6),
                                                        borderSide: BorderSide(color: Colors.blue, width: 2), // optional
                                                      ),
                                                    ),
                                                    style: TextStyle(fontSize: 13),
                                                    keyboardType: TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                SizedBox(
                                                  height: 35, // 👈 your desired height
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      final input = _pageNumberController.text.trim();
                                                      final page = int.tryParse(input)! + 7;
                                                      if (page >= 0 && page < Utils.bookPages.length) {
                                                        _pageController.jumpToPage(page);
                                                        _showGoToContainer.value = false;
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: Size(80, 48), // optional: controls size
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(6), // 👈 sets roundness
                                                      ),
                                                    ),
                                                    child: Text('GO'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          /// your existing go-to-page section
                                        ],
                                        ValueListenableBuilder<Map<String, double>>(
                                          valueListenable: fontSizes,
                                          builder: (context, value, _) {
                                            return SizedBox(height: 30,
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                                children: [
                                                  // ... other buttons remain the same
                                                  SizedBox(width:40,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.exit_to_app,
                                                          color: Colors.red),
                                                      tooltip: 'Exit',
                                                      padding: EdgeInsets.zero,
                                                      constraints: BoxConstraints(),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context); // Manually go back
                                                      },
                                                    ),
                                                  ),

                                                  Expanded(
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SizedBox(width: 0), // horizontal space

                                                          IconButton(
                                                            icon: const Icon(Icons.arrow_back_ios,
                                                                color: Colors.white),
                                                            tooltip: 'Next Page',
                                                            padding: EdgeInsets.zero,
                                                            constraints: BoxConstraints(),
                                                            onPressed: () {
                                                              _pageController.nextPage(
                                                                  duration:
                                                                  Duration(milliseconds: 300),
                                                                  curve: Curves.easeInOut);
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons.zoom_in,
                                                                color: Colors.white),
                                                            tooltip: 'Zoom In',
                                                            padding: EdgeInsets.zero,
                                                            constraints: BoxConstraints(), // ← This removes the minimum size constraint
                                                            onPressed: () {
                                                              _showZoomToolbar.value = !_showZoomToolbar.value;
                                                              //
                                                              // if (fontSizes.value['size1']! <
                                                              //     28.0) {
                                                              //   fontSizes.value = {
                                                              //     'size1':
                                                              //     fontSizes.value['size1']! + 1,
                                                              //   };
                                                              // }
                                                            },
                                                          ),
                                                          // if (fontSizes.value['size1']! < 13.0 ||
                                                          //     fontSizes.value['size1']! > 15.0)
                                                          //   IconButton(
                                                          //     icon: const Icon(Icons.zoom_in_map,
                                                          //         color: Colors.white),
                                                          //     tooltip: '100% Zoom',
                                                          //     padding: EdgeInsets.zero,
                                                          //     constraints: BoxConstraints(), // ← This removes the minimum size constraint
                                                          //     onPressed: () {
                                                          //       fontSizes.value = {
                                                          //         'size1': 14,
                                                          //       };
                                                          //     },
                                                          //   )
                                                          // else
                                                          //   IconButton(
                                                          //     icon: const Icon(Icons.zoom_out_map,
                                                          //         color: Colors.transparent),
                                                          //     tooltip: '100% Zoom',
                                                          //     padding: EdgeInsets.zero,
                                                          //     constraints: BoxConstraints(),
                                                          //     onPressed: () {
                                                          //       // fontSizes.value = {
                                                          //       //   'size1': 14,
                                                          //       // };
                                                          //     },
                                                          //   ),

                                                          // TextButton(
                                                          //   onPressed: () {
                                                          //     fontSizes.value = {
                                                          //       'size1':14,
                                                          //     };
                                                          //     // Handle zoom level click here
                                                          //     print(
                                                          //         "Zoom level clicked: ${fontSizes.value['size1']!.toInt()}");
                                                          //   },
                                                          //   child: Text(
                                                          //     "100%",
                                                          //     style: const TextStyle(
                                                          //         color: Colors.white, fontSize: 16),
                                                          //   ),
                                                          // ),

                                                          // IconButton(
                                                          //   icon: const Icon(Icons.zoom_out,
                                                          //       color: Colors.white),
                                                          //   tooltip: 'Zoom Out',
                                                          //   padding: EdgeInsets.zero,
                                                          //   constraints: BoxConstraints(),
                                                          //   onPressed: () {
                                                          //     if (fontSizes.value['size1']! > 8.0) {
                                                          //       fontSizes.value = {
                                                          //         'size1':
                                                          //         fontSizes.value['size1']! - 1,
                                                          //       };
                                                          //     }
                                                          //   },
                                                          // ),

                                                          ValueListenableBuilder<
                                                              Map<String, dynamic>>(
                                                            valueListenable: pageState,
                                                            builder: (_, state, __) {
                                                              int pageNum =
                                                                  state['currentPage'] - 7;
                                                              bool isFavorite = (state['favorites']
                                                              as Map<int, bool>)
                                                                  .containsKey(pageNum);

                                                              return IconButton(
                                                                icon: Icon(
                                                                  isFavorite
                                                                      ? Icons.favorite
                                                                      : Icons.favorite_border,
                                                                  color: isFavorite
                                                                      ? Colors.red
                                                                      : Colors.white,
                                                                ),
                                                                padding: EdgeInsets.zero,
                                                                constraints: BoxConstraints(),
                                                                onPressed: () {
                                                                  if (pageNum > 0) {
                                                                    final newFavorites =
                                                                    Map<int, bool>.from(
                                                                        state['favorites']);
                                                                    if (isFavorite) {
                                                                      FavoritePageStorage
                                                                          .removeFavorite(pageNum);
                                                                      newFavorites.remove(pageNum);
                                                                    } else {
                                                                      FavoritePageStorage
                                                                          .addFavorite(pageNum);
                                                                      newFavorites[pageNum] = true;
                                                                    }
                                                                    pageState.value = {
                                                                      ...state,
                                                                      'favorites': newFavorites,
                                                                    };
                                                                  } else {
                                                                    ScaffoldMessenger.of(context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                          content: Text(
                                                                              'This page cannot be bookmarked')),
                                                                    );
                                                                  }
                                                                },
                                                              );
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              showContainer
                                                                  ? Icons.close
                                                                  : Icons.read_more,
                                                              color: Colors.white,
                                                            ),
                                                            padding: EdgeInsets.zero,
                                                            constraints: BoxConstraints(),
                                                            onPressed: () {
                                                              _showGoToContainer.value =
                                                              !showContainer;
                                                              if (!showContainer) {
                                                                _pageNumberController.clear();
                                                              }
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.arrow_forward_ios,
                                                                color: Colors.white),
                                                            tooltip: 'Previous Page',
                                                            padding: EdgeInsets.zero,
                                                            constraints: BoxConstraints(),
                                                            onPressed: () {
                                                              _pageController.previousPage(
                                                                  duration:
                                                                  Duration(milliseconds: 300),
                                                                  curve: Curves.easeInOut);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                              // ValueListenableBuilder<bool>(
                                              //   valueListenable: _isDark,
                                              //     builder: (context, isDark, _) {
                                              //     return
                                              //     GestureDetector(
                                              //       onTap: () {
                                              //         themeProvider.setThemeMode(!isDark);
                                              //         // setState(() {
                                              //         //   _isDark = !_isDark;
                                              //         // });
                                              //       },
                                              //       child: AnimatedSwitcher(
                                              //           duration: const Duration(milliseconds: 300),
                                              //           transitionBuilder: (child, animation) {
                                              //             return RotationTransition(
                                              //                 turns: animation, child: child);
                                              //           },
                                              //           child: Image.asset(
                                              //             isDark
                                              //                 ? 'assets/images/icon_night.png'
                                              //                 : 'assets/images/icon_day.png',
                                              //             key: ValueKey(isDark),
                                              //             width:   30,
                                              //             height:  30,
                                              //
                                              //           )
                                              //
                                              //         // Icon(
                                              //         //   AssetImage('assets/images/sakoon_cover.jpg') as IconData?,
                                              //         //   key: const ValueKey('dark'),
                                              //         //   color: Colors.orange,
                                              //         //   size: 60,
                                              //         // )
                                              //         //     :ImageIcon(
                                              //         //   size: 60,
                                              //         //   AssetImage('assets/images/icon_day.png'),
                                              //         //   key: const ValueKey('dark'),
                                              //         // ),
                                              //       ),
                                              //     );
                                              //   }),



                                                  SizedBox(width: 40)
                                                  // ... other buttons
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                        /// your existing font size and navigation buttons
                                        /// BUT — add a collapse button at the end like this:

                                        SizedBox(height:20,
                                          child: GestureDetector(
                                            onTap: () => _showToolbar.value = false,
                                            child: Container(
                                              color: Colors.black,
                                              height: 20,
                                              alignment: Alignment.center,
                                              child: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.center,
                                        //   children: [
                                        //     IconButton(
                                        //       icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                        //       tooltip: 'Collapse Toolbar',
                                        //       onPressed: () {
                                        //         _showToolbar.value = false;
                                        //       },
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )

                ],
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // _disableSecureScreen();
    // WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    _showGoToContainer.dispose();
    _pageNumberController.dispose();
    super.dispose();
  }

  // Handle app lifecycle changes
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     _enableSecureScreen();
  //   }
  // }
  //
  // Future<void> _enableSecureScreen() async {
  //   try {
  //     await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  //   } catch (e) {
  //     debugPrint("Error enabling secure screen: $e");
  //   }
  // }
  //
  // Future<void> _disableSecureScreen() async {
  //   try {
  //     await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  //   } catch (e) {
  //     debugPrint("Error disabling secure screen: $e");
  //   }
  // }

  String removeFootnotes(String markdown) {
      // Remove inline footnote references like [^1]
    String noDefinitions = markdown.replaceAll(
      RegExp(r'^\[\^.+?\]:.*$', multiLine: true),
      '',
    );

    // Step 2: Remove all inline footnote references
    String noReferences = noDefinitions.replaceAll(
      RegExp(r'\[\^.+?\]'),
      '',
    );

    return noReferences;



    //
    // // Remove footnote references like [^1]
    // String withoutReferences2 = fullyHidden.replaceAll(RegExp(r'\[\^.+?\]'), '');
    //
    // // Remove footnote definitions like [^1]: Footnote text
    // String cleanedMarkdown = withoutReferences.replaceAll(RegExp(r'^\[\^.+?\]:.*$', multiLine: true), '');
    //
    // return cleanedMarkdown.trim();
  }

  Widget _buildCollapsedView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("فوټ نوټونه وښایاست", style: TextStyle(color:Theme.of(context).colorScheme.onError,fontSize: 9, fontFamily: 'mitra_regular', fontStyle: FontStyle.italic )),
        Icon(Icons.keyboard_arrow_up,  size: 15, color:Theme.of(context).colorScheme.onError),
      ],
    );
  }

  Widget _buildExpandedView(String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              color:Theme.of(context).colorScheme.onError,
              fontSize: 13,
              fontFamily: 'mitra_regular',
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        // const SizedBox(height: 5),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   crossAxisAlignment: CrossAxisAlignment.center, // This helps too
        //   children: [
        //     Icon(Icons.keyboard_arrow_down, size: 15, color:Theme.of(context).colorScheme.onError),
        //     SizedBox(width: 4),
        //   ],
        // ),
      ],
    );

  }

  pageChanged(int index) {
    if (!ip.value["ip"]! && index >= l - 1) {
      _showPurchaseBottomSheet(context);
    }
    print("DataSaved:$index");
    pageState.value = {
      ...pageState.value,
      'currentPage': index,
    };
    print("changeddd");
    Utils.saveInt(Utils.indexKey, currentPageNumber);
  }

  void _showPurchaseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo ended. Purchase full book to unlock the full book.',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'mitra_bold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text('Purchase'),
                    onPressed: () {
                      // Add your purchase logic here
                      print('Purchase button clicked');
                      Navigator.pop(context); // Close the bottom sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          // child: IAPBottomSheet(),
                        ),
                      );
                      // You would typically call your in-app purchase flow here
                      // For example:
                      // _makePurchase(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _NoIconLinkBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {

    // String s1 = element.footnoteLabel.toString();
    // String s2 = element.attributes.toString();
    // print("element: __ $s1 __ $s2");
    // final href = element.attributes['href'];
    // // Skip footnote links (e.g., [^1] => href="#fn1")
    // if (href != null && href.startsWith('#')) {
    //   return const SizedBox.shrink(); // Hide footnote symbol
    // }
    // Let all other <a> elements render as default (email, URLs, etc.)
    return null; // <- Important: allows flutter_markdown to handle it


    // final href = element.attributes['href'];
    //
    // // Handle footnote references (the [^1] links)
    // if (href != null && href.startsWith('#')) {
    //   return Text(
    //     element.textContent,
    //     style: preferredStyle?.copyWith(
    //       color: Colors.blue, // Match your footnote color
    //       fontSize: preferredStyle.fontSize! * 0.8, // Make slightly smaller
    //     ),
    //   );
    }

    // Let all other <a> elements render as default
    // return null;

  }


Map<int, String> extractFootnotes(String markdown) {
  final footnotes = <int, String>{};
  final regex = RegExp(r'^\[\^([^\]]+)\]:\s*(.+)$', multiLine: true);

  int i = 1;
  for (final match in regex.allMatches(markdown)) {
    final key = match.group(1)!;
    final value = match.group(2)!;
    footnotes[i] = value;
    print("Value: "+value.replaceAll(":", ""));
    print("key: "+key);
    i++;
  }

  return footnotes;
}

