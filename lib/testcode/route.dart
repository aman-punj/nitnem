//
// dynamic? sendRoute(BuildContext context, RoutesNames s,
//     {
//       bool isreplace = false,
//     bool clearstack = false,
//     Function? onrefresh,
//     Map<String, dynamic>? data
//     }) {
//   dynamic widget = null;
//   switch (s) {
//     case RoutesNames.splash:
//       widget = SplashScreen();
//       break;
//
//     case RoutesNames.onboarding:
//       sendActivity(context, OnBoardingScreen(),
//           isreplace: isreplace, clearstack: clearstack);
//       break;
//
//     case RoutesNames.welcome:
//       sendActivity(
//           context,
//           MultiBlocProvider(
//             providers: [
//               BlocProvider<SendOtpBloc>(
//                 create: (context) =>
//                     SendOtpBloc(repository: SendOtpRepositoryImpl()),
//               ),
//               BlocProvider<SendOtpCustomerBloc>(
//                 create: (context) => SendOtpCustomerBloc(
//                     repository: SendOtpCustomerRepositoryImpl()),
//               ),
//               BlocProvider<CheckUserTypeBloc>(
//                 create: (context) => CheckUserTypeBloc(
//                     repository: CheckUserTypeRepositoryImpl()),
//               ),
//               BlocProvider<CheckLoginCustomerBloc>(
//                 create: (context) => CheckLoginCustomerBloc(
//                     repository: CheckLoginCustomerRepositoryImpl()),
//               ),
//               BlocProvider<ForgotPasswordBloc>(
//                 create: (context) => ForgotPasswordBloc(
//                     repository: ForgotPasswordRepositoryImpl()),
//               ),
//             ],
//             child: WelcomeScreen(),
//           ),
//           isreplace: isreplace,
//           clearstack: clearstack);
//       break;
//
//     case RoutesNames.maps:
//       widget = sendActivity(context, MapsScreen(),
//           isreplace: isreplace, clearstack: clearstack);
//       break;
//
//     case RoutesNames.settings:
//       sendActivity(context, SettingScreen(),
//           isreplace: isreplace, clearstack: clearstack);
//       break;
//   }
//   return widget;
// }
//
// enum RoutesNames {
//   splash,
//   onboarding,
//   welcome,
//   signup,
//   verification,
//   dashboard,
//   business,
//   home,
//   history,
//   profile,
//   genealogy,
//   level_summary,
//   level_detail,
//   level_status_bv,
//   royalty_graph,
//   achievement,
//   tsp_achiever,
//   gallery,
//   gallery_list,
//   pdf_list,
//   income_summary,
//   income_statement,
//   complaint,
//   complaint_list,
//   complaint_detail,
//   zoom_meeting,
//   wallet_statement,
//   withdrawal,
//   income_account,
//   under_maintenance,
//   distributor_profile,
//   change_password,
//   pan,
//   bank,
//   upi_verify,
//   address,
//   customer_profile_update,
//   basic_info,
//   best_performer_achiever,
//   add_money,
//   mobile_recharge,
//   contact,
//   select_provider,
//   bbps_recharge,
//   bbps_transaction,
//   bbps_complaint,
//   bbps_complaint_list,
//   loan,
//   offer_master,
//   offer_achiever,
//   payment,
//   loan_application,
//   vendor_registration,
//   maps,
//   franchise_list,
//   settings,
//   test,
//   test_ragistration, prayerPage
// }
