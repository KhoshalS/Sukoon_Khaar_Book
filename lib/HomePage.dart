import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sakoon_shar/FavoritePageStorage.dart';
import 'package:sakoon_shar/IAPScreen.dart';
import 'package:sakoon_shar/TableOfContent.dart';
import 'package:sakoon_shar/Utils.dart';

import 'CustomColors.dart';
import 'FavoritePageGrid.dart';
import 'ThemeProvider.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Method to load data
  @override
  void initState() {
    super.initState();
    _loadFontSize();
    loadIp();

  }


  bool showBtn = false;

  loadIp() async {
    await Utils.loadBool(Utils.ip).then((result) {
      setState(() {
        showBtn = !result;
      });
      return false;
    });

  }

  @override
  Widget build(BuildContext context) {
    // final brightness = MediaQuery.of(context).platformBrightness;
    // isDarkMode = brightness == Brightness.dark;
    //final themeProvider = Provider.of<ThemeProvider>(context);

    bool isDarkMode = ThemeProvider.isDark;
    print("X_$isDarkMode");
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Color(0xFFEADBCB), // Or any custom color
    //   statusBarIconBrightness: Brightness.dark, // For dark icons on light background
    //   statusBarBrightness: Brightness.light, // For iOS (status bar text color)
    // ));
    // isDarkMode = ThemeMode..toString().split('.').last.toString()!="light";

    return Scaffold(
        appBar: AppBar(
          // iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface), // change arrow color
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          toolbarHeight: 0,
        ),


        body: SafeArea(
        child: Stack(
        alignment: Alignment.center,
        children: [
          // 🎨 Gradient overlay (semi-transparent black)
          Container(
            decoration: BoxDecoration(
              color: Color(
                  0xFFd8d2c6), // This will show when image doesn't fill the space
              image: DecorationImage(
                image: AssetImage('assets/images/sakoon_cover.jpg'),
                fit: BoxFit.fitHeight,
                scale: 2, // Changed from fill to cover
                alignment: Alignment.center, // Center the image
              ),
            ),
            constraints: BoxConstraints
                .expand(), // Ensure container fills available space
          ),
          // 🌑 Radial Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: isDarkMode?1.3:1.0, // Increase for wider coverage
                  colors: [
                    Colors.black.withValues(alpha: isDarkMode?0.6:0.4), // Center is darker
                    Colors.transparent, // Edge is clear
                  ],
                  stops: [0.0, 3.0],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SwitchListTile(
                  //   title: Text("Night Mode"),
                  //   value: isDark,
                  //   onChanged: (val) {
                  //     themeProvider.setThemeMode(val?ThemeMode.dark:ThemeMode.light);
                  //   },
                  // ),

                  SizedBox(height: 60),
                  SizedBox(
                    width: 200,
                    height: 60, // Fixed height
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xf2d8d0b8),
                        ),
                        onPressed: () {
                          if (Utils.updateFontSize != 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyHomePage(
                                        index: 0,
                                        size1: Utils.updateFontSize,
                                      )),
                            );
                          } else {
                            _loadFontSize();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Try Again!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'د سکون ښار لوست',
                          style: TextStyle(
                            color: Color(0xff1b5a4b),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  // SizedBox(height: 16),
                  // ElevatedButton.icon(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xff1b5a4b),
                  //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //   ),
                  //   onPressed: () {
                  //     // You can trigger purchase, unlock flow, or bottom sheet here
                  //     showModalBottomSheet(
                  //       context: context,
                  //       isScrollControlled: true,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  //       ),
                  //       builder: (_) => Padding(
                  //         padding: MediaQuery.of(context).viewInsets,
                  //         child: IAPBottomSheet(),
                  //       ),
                  //     );
                  //   },
                  //   icon: Icon(Icons.lock_open, color: Colors.white),
                  //   label: Text(
                  //     'Unlock Full Book',
                  //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  //   ),
                  // ),

                  SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xf2d8d0b8),
                        ),
                        onPressed: () {
                          _loadSavedData();
                        },
                        child: Text(
                          'د پخواني لوست ادامه',
                          style: TextStyle(
                            color: Color(0xff1b5a4b),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xf2d8d0b8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TableOfContent()),
                          );
                        },
                        child: Text(
                          'لړلیک',
                          style: TextStyle(
                            color: Color(0xff1b5a4b),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xf2d8d0b8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FavoritePagesScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'نښه شوې پاڼې',
                          style: TextStyle(
                            color: Color(0xff1b5a4b),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xf2d8d0b8),
                      ),
                      onPressed: () {
                        _showBottomSheet(context);
                      },
                      child: Text(
                        'د کتاب په اړه',
                        style: TextStyle(
                          color: Color(0xff1b5a4b),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ),

          Positioned(
            right: 10,
            top: 15,
            child:
            Card(
              elevation: isDarkMode?2:4,
              color: isDarkMode?Color(0xffc8c2b6):Color(0xFFd8d2c6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    // themeProvider.setThemeMode(!isDarkMode);
                    // setState(() {
                    //   isDarkMode = !isDarkMode;
                    // });
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: child,
                      );
                    },
                    child:
                    Stack(
                      children: [
                        // Shadow layer
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Image.asset(
                            isDarkMode
                                ? 'assets/images/icon_night.png'
                                : 'assets/images/icon_day.png',
                            key: ValueKey('shadow_${isDarkMode.toString()}'),
                            width: 30,
                            height: 30,
                            color: Colors.black54.withAlpha(60),
                          ),
                        ),

                        // Main image
                        Image.asset(
                          isDarkMode
                              ? 'assets/images/icon_night.png'
                              : 'assets/images/icon_day.png',
                          key: ValueKey(isDarkMode),
                          width: 30,
                          height: 30,
                        ),
                      ],
                    )

                    // Image.asset(
                    //   isDarkMode
                    //       ? 'assets/images/icon_night.png'
                    //       : 'assets/images/icon_day.png',
                    //   key: ValueKey(isDarkMode),
                    //   width: 30,
                    //   height: 30,
                    // ),
                    //

                  ),
                ),
              ),
            )

            // GestureDetector(
            //   onTap: () {
            //     themeProvider.setThemeMode(!isDarkMode);
            //     setState(() {
            //       isDarkMode = !isDarkMode;
            //     });
            //   },
            //   child: AnimatedSwitcher(
            //       duration: const Duration(milliseconds: 300),
            //       transitionBuilder: (child, animation) {
            //         return RotationTransition(
            //             turns: animation, child: child);
            //       },
            //       child: Image.asset(
            //         isDarkMode
            //             ? 'assets/images/icon_night.png'
            //             : 'assets/images/icon_day.png',
            //         key: ValueKey(isDarkMode),
            //         width:   30,
            //         height:  30,
            //
            //       )
            //
            //     // Icon(
            //     //   AssetImage('assets/images/sakoon_cover.jpg') as IconData?,
            //     //   key: const ValueKey('dark'),
            //     //   color: Colors.orange,
            //     //   size: 60,
            //     // )
            //     //     :ImageIcon(
            //     //   size: 60,
            //     //   AssetImage('assets/images/icon_day.png'),
            //     //   key: const ValueKey('dark'),
            //     // ),
            //   ),
            // ),
            //
          ),


          if(showBtn)Positioned(
            bottom: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff1b5a4b),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // You can trigger purchase, unlock flow, or bottom sheet here
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
                },
                icon: Icon(Icons.lock_open, color: Colors.white),
                label: Text(
                  'Unlock Full Book',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void _loadSavedData() async {
    int loadedData = await Utils.loadInt(Utils.indexKey);

    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(
                  index: loadedData,
                  size1: Utils.updateFontSize,
                )),
      );
      print('Continue clicked $loadedData');
    });
  }

  void _loadFontSize() async {
    Utils.updateFontSize = await Utils.loadDouble(Utils.fontSize1);
    print('Font Size updated');
  }


  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for allowing full height scroll
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'سکون ښار',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    sukoonDescription,
                    style: TextStyle(fontSize: 16),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            );
          },
        );
      },
    );}
  // void _showBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SingleChildScrollView(
  //               child: Text(
  //                 'د کتاب په اړه',
  //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //             SizedBox(height: 10),
  //             Text(sukoonDescription,
  //               style: TextStyle(fontSize: 16),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  String sukoonDescription = '''
سکون ښار د عبیدالله حسام لومړی کتاب دی چې د شاوخوا یوې لسیزې د مطالعې، تجربو او زدکړو نچوړ دی.
په دغه موده کې نوموړي د لسګونه تکړه علماوو د سلګونه کتابونو، مقالو او ویډیوګانو په لوستلو او کتلو خپل فکر غني کړی او د هغې په بنسټ یې ستاسې درنو لوستونکو لپاره د سکون ښار کتاب لیکلی دی.
دا کتاب به تاسې سره د خوشحاله زړه او روحي سکون ترلاسه کولو ترڅنګ د بریالي شخصیت درلودو کې مرسته وکړي ان شاء الله.
په افغانستان او بهرنیو هېوادونو کې زموږ د ګرانو هېوادوالو لخوا د سکون ښار پراخ او تود هرکلي دې ته وهڅولو چې ددې کتاب مبایل اپلیکشن هم جوړ کړو تر څو ورته هرځای خلک لاسرسی ولري او په ترلاسه کولو کې یې په زحمت نه شي.
د دې کتاب چاپ شوې بڼه د افغانستان په معتبرو کتاب پلورنځیو کې ترلاسه کېدای شي.
همداراز تاسې کوای شئ غربي هېوادونو کې یې له لاندې ویب پاڼې څخه انلاین ارډر کړئ، چاپ شوې بڼه به یې  ستاسې تر کورونو در ورسیږي.
ددې کتاب لیکل په داسې بڼه شوي چې تر لوستو وروسته یې له مطالعې سره ستاسې لېوالتیا پیدا شي. په همدې هیله!
که د سکون ښار له لوستلو سره مو مثبت بدلون احساس کړ، موږ له دعا هېر نه کړئ!

وېب سایټ: www.sukoonkhaar.com
اېمېل ادرس: info@sukoonkhaar.com
واټس اپ: 0093772051025
د دې کتاب هر ډول چاپ او خپرولو حقوق له لیکوال سره خوندي دي.
''';

}



