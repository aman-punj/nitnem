// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gpayapp/Bloc/CheckUserTypeBloc.dart';
// import 'package:gpayapp/Bloc/SendOtpBloc.dart';
// import 'package:gpayapp/Utils/colors.dart';
// import 'package:gpayapp/Utils/images.dart';
// import 'package:gpayapp/routes/route.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'onboarding_screen.dart';
// import 'DashboardScreen.dart';
// import '../Utils/common_widget.dart';
//
// class SplashScreen extends StatefulWidget {
//   SplashScreen({Key? key}) : super(key: key);
//
// //final SplashController splashController = Get.put(SplashController());
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     isFirstTime();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorResources.white,
//       body: Center(
//         child: Image.asset(Images.appLogo),
//       ),
//     );
//   }
//
//   Widget sendDashboardscreen() {
//     return MultiBlocProvider(
//       providers: [
//         /*BlocProvider<CheckStatusBloc>(
//             create: (context) =>
//                 CheckStatusBloc(repository: CheckStatusRepositoryImpl())),
//         BlocProvider<GetUserDataBloc>(
//           create: (context) =>
//               GetUserDataBloc(repository: GetUserDataRepositoryImpl()),
//         ),
//         BlocProvider<DashboardBloc>(
//           create: (context) =>
//               DashboardBloc(repository: DashboardRepositoryImpl()),
//         ),*/
//       ],
//       child: DashboardScreen(),
//     );
//   }
//
//   Widget sendLoginscreen() {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<SendOtpBloc>(
//             create: (context) =>
//                 SendOtpBloc(repository: SendOtpRepositoryImpl())),
//         BlocProvider<CheckUserTypeBloc>(
//           create: (context) =>
//               CheckUserTypeBloc(repository: CheckUserTypeRepositoryImpl()),
//         ),
//       ],
//       child: OnBoardingScreen(),
//     );
//   }
//
//   var db = FirebaseFirestore.instance;
//
//   void isFirstTime() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//
//     String version = packageInfo.version;
//     String os_name = "android";
//     if (Platform.isIOS) {
//       os_name = "ios";
//     } else {
//       os_name = "android";
//     }
//     String latest_version = "1.0.0";
//     String upcoming_latest_version = "1.0.0";
//     await db.collection("app_info").get().then((event) {
//       for (var doc in event.docs) {
//         if (Platform.isIOS) {
//           latest_version = doc.get("ios_version");
//         } else {
//           latest_version = doc.get("android_version");
//           upcoming_latest_version = doc.get("upcoming_android_version");
//         }
//       }
//     });
//
//     debugPrint("version:$version os:$os_name");
//     SharedPreferences pref = await SharedPreferences.getInstance();
//
//     if (version != latest_version && version != upcoming_latest_version) {
//       Custom_Dialog(
//           mcontext: context,
//           message: "New Version available,\nplease update your app",
//           positive_btn_text: "OK",
//           dismissable: os_name == "ios" ? true : false,
//           negative_btn_text: os_name == "ios" ? "Skip" : "",
//           isClose: false,
//           dismissDialog: false,
//           onnegative_press: () {
//             sendForward();
//           },
//           onpress: () {
//             pref.clear();
//             openLinks('https://play.google.com/store/apps/details?id=${packageInfo.packageName}');
//             //LaunchReview.launch(writeReview: false,iOSAppId: "0",androidAppId: "com.gatitechnology.provedaindia");
//           }).show();
//     } else {
//       sendForward();
//     }
//   }
//
//   sendForward() async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     var isFirstTime = pref.getBool('first_time');
//     if (isFirstTime == null) {
//       pref.setBool('first_time', false);
//     }
//
//     var islogin = pref.getBool("isLogin");
//     if (islogin == null) {
//       islogin = false;
//     }
//     Future.delayed(const Duration(milliseconds: 1000), () {
//       !islogin!
//           ?
//           // uncomment the next line
//       // sendRoute(context, RoutesNames.onboarding, clearstack: true)
//       sendRoute(context, RoutesNames.test_ragistration, clearstack: true)
//
//           : sendRoute(context, RoutesNames.dashboard, clearstack: true);
//       /*Navigator.pushReplacement(
//         context,
//         PageTransition(
//             type: PageTransitionType.rightToLeft,
//             child: ),
//       );*/
//     });
//   }
// }
