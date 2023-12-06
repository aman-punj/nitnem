// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:nitnem/Pages/my_home-page.dart';
// import 'package:nitnem/Pages/prayer_page.dart';
//
// import '../utils/prayer_files/hindi_prayer.dart';
// import '../utils/prayer_files/punjabi_prayer.dart';
//
// dynamic? sendRoute(BuildContext context, RoutesNames s,
//     {bool isreplace = false,
//     bool clearstack = false,
//     Function? onrefresh,
//     Map<String, dynamic>? data}) {
//   dynamic widget = null;
//   switch (s) {
//
//     // case RoutesNames.splash:
//     //   widget = SplashScreen();
//     //   break;
//
//     case RoutesNames.homeScreen:
//       sendActivity(context, const MyHomePage(),
//           isreplace: isreplace, clearstack: clearstack);
//       break;
//
//     case RoutesNames.prayerPage:
//       sendActivity(context,   PrayerPage(
//         prayerText: widget.isPunjabiSelected
//             ? punjabiPrayer[widget.num]
//             : hindiPrayer[widget.num],
//         prayerName: widget.isPunjabiSelected
//             ? widget.text1
//             : widget.text2,
//       ) as MyHomePage,
//           // isreplace: isreplace, clearstack: clearstack
//       );
//
//   }
//   return widget;
// }
//
// void sendActivity(BuildContext context, MyHomePage myHomePage,
//     { bool? isreplace, required bool? clearstack}) {}
//
// enum RoutesNames {
//   // splash,
//   homeScreen,
//   prayerPage }
