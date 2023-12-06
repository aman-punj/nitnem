// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gpayapp/Bloc/TestBloc.dart';
// import 'package:gpayapp/Bloc/DesignationListBloc.dart';
// import 'package:gpayapp/Utils/colors.dart';
// import 'package:gpayapp/data/model/testBean.dart';
// import 'package:gpayapp/data/model/DesignationListBean.dart';
// import 'package:gpayapp/main.dart';
// import 'package:intl/intl.dart';
// import 'package:lazy_data_table/lazy_data_table.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:photo_view/photo_view.dart';
// import '../../Utils/CustomButtonWidget.dart';
// import '../../Utils/CustomTextWidget.dart';
// import '../../Utils/common_widget.dart';
//
// import '../../Utils/strings.dart';
// import '../../routes/route.dart';
// import '../Utils/images.dart';
//
// class TestScreen extends StatefulWidget {
//   Map<String, dynamic>? data;
//
//   TestScreen({Key? key, Map<String, dynamic>? data}) : super(key: key) {
//     this.data = data;
//   }
//
//   @override
//   _TestScreenState createState() => _TestScreenState(intent_data: data);
// }
//
// class _TestScreenState extends State<TestScreen> {
//   Map<String, dynamic>? intent_data;
//
//   _TestScreenState({this.intent_data});
//
//   TextEditingController from_date = TextEditingController();
//   TextEditingController to_date = TextEditingController();
//
//   TestBloc? testBloc;
//   TestBean? testBean;
//
//   List<String> headers = [
//     "Subject",
//     "Complain",
//     "Date",
//     "Nature",
//     "Mobile",
//     "Email",
//     "Status",
//     "Reply",
//     "Reply Date",
//     "Image",
//     "Details",
//   ];
//
//   LoadingDialog? pr;
//
//   @override
//   void initState() {
//     super.initState();
//     pr = LoadingDialog(
//         context: context,
//         dismissable: AppConstants.progress_dismissiable,
//         title: CustomTextWidget(
//           "Loading",
//           size_txt: 18.sp,
//           color_txt: Colors.black,
//           isbold: true,
//         ),
//         message: CustomTextWidget(
//           "Please wait, we are processing your data",
//           max_lines: 2,
//           size_txt: 12.sp,
//         ));
//
//     initView();
//   }
//
//   initView() {
//     testBloc = BlocProvider.of<TestBloc>(context);
//
//     String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
//     String formattedDate_to = DateFormat('dd/MM/yyyy').format(DateTime.now());
//
//     setState(() {
//       from_date.text = formattedDate;
//       to_date.text = formattedDate_to;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         BlocListener<TestBloc, TestState>(
//           listener: (context, state) async {
//             if (state is TestErrorState) {
//               pr!.dismiss();
//               debugPrint(state.message);
//               Custom_Dialog(
//                       mcontext: context,
//                       message: state.message,
//                       positive_btn_text: "OK")
//                   .show();
//             } else if (state is TestCloseState) {
//               pr!.dismiss();
//               debugPrint(state.message);
//               Custom_Dialog(
//                   mcontext: context,
//                   message: state.message,
//                   positive_btn_text: "Proceed",
//                   dismissable: false,
//                   isClose: true,
//                   onpress: () {
//                     sendRoute(
//                         PrefUtil.navKey.currentContext!, RoutesNames.welcome,
//                         clearstack: true);
//                   }).show();
//             } else if (state is TestInitialState) {
//               pr!.show();
//             } else if (state is TestLoadingState) {
//               pr!.show();
//             } else if (state is TestLoadedState) {
//               pr!.dismiss();
//               setState(() {
//                 testBean = state.Tests;
//               });
//             }
//           },
//         ),
//       ],
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 30.w),
//               child: Column(
//                 children: [
//                   SizedBox(height: 50),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           onbackpress(context);
//                         },
//                         child: Container(
//                           height: 40,
//                           width: 40,
//                           decoration: BoxDecoration(
//                             color: ColorResources.white,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                                 color: ColorResources.greyE5E, width: 1),
//                           ),
//                           child: Center(
//                             child: Icon(
//                               Icons.arrow_back_ios_outlined,
//                               color: ColorResources.black,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                       CustomTextWidget(
//                         'Test Enquiry',
//                         size_txt: 20.sp,
//                         isbold: true,
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: builddateLayout(from_date, to_date),
//             ),
//             SizedBox(height: 10.h),
//             CustomButtonWidget(
//               'Show Data',
//               txt_color: Colors.white,
//               onpressed: () async {
//                 testBloc!.add(FetchTestsEvent({
//                   "memberid": '1256454',
//                   "fromdate": from_date.text.toString(),
//                   "todate": to_date.text.toString(),
//                 }));
//               },
//             ),
//             SizedBox(height: 20.h),
//             testBean != null
//                 ? Expanded(
//                     child: LazyDataTable(
//                       rows: testBean!.data!.length,
//                       columns: headers.length,
//                       tableTheme: LazyDataTableTheme(
//                           columnHeaderColor: ColorResources.columnHeaderColor,
//                           columnHeaderBorder: Border.all(
//                               color: ColorResources.columnHeaderBorderColor),
//                           rowHeaderColor: ColorResources.rowHeaderColor,
//                           cornerBorder:
//                               Border.all(color: ColorResources.cornerBorder),
//                           cornerColor: ColorResources.cornerColor,
//                           alternateRow: false,
//                           alternateColumn: false),
//                       tableDimensions: LazyDataTableDimensions(
//                         cellHeight: 60.h,
//                         cellWidth: 79.w,
//                         topHeaderHeight: 40.h,
//                         leftHeaderWidth: 42.h,
//                         // customCellWidth:  {0:70.w,3: 70.h},
//                       ),
//                       topHeaderBuilder: (i) => buildcontainer(headers[i],
//                           isbold: true, isheader: true),
//                       leftHeaderBuilder: (i) => buildcontainer("${i + 1}",
//                           isbold: true, size_txt: 14.sp),
//                       dataCellBuilder: (i, j) => j == 0
//                           // "Subject",
//                           // "Complain",
//                           // "Date",
//                           // "Nature",
//                           // "Mobile",
//                           // "Email",
//                           // "Status",
//                           // "Reply",
//                           // "Reply Date",
//                           // "Image",
//                           // "Details",
//                           ? buildcontainer(testBean!.data![i].subject!)
//                           : j == 1
//                               ? buildcontainer(
//                                   "${testBean!.data![i].complain!}")
//                               : j == 2
//                                   ? buildcontainer(
//                                       "${testBean!.data![i].comdate!}")
//                                   : j == 3
//                                       ? buildcontainer(
//                                           "${testBean!.data![i].nature!}")
//                                       : j == 4
//                                           ? buildcontainer(
//                                               "${testBean!.data![i].mobileno!}")
//                                           : j == 5
//                                               ? buildcontainer(
//                                                   "${testBean!.data![i].email!}")
//                                               : j == 6
//                                                   ? buildcontainer(
//                                                       "${checkString(testBean!.data![i].status, isempty: true)}")
//                                                   : j == 7
//                                                       ? buildcontainer(
//                                                           "${checkString(testBean!.data![i].replay, isempty: true)}")
//                                                       : j == 8
//                                                           ? buildcontainer(
//                                                               "${checkString(testBean!.data![i].repdate, isempty: true)}")
//                                                           : j == 9
//                                                               ? buildcontainer(
//                                                                   "View Image",
//                                                                   isbold: true,
//                                                                   txt_color:
//                                                                       Colors
//                                                                           .green,
//                                                                   onpressed:
//                                                                       () {
//                                                                   imagedialog(AppConstants
//                                                                           .Url +
//                                                                       testBean!
//                                                                           .data![
//                                                                               i]
//                                                                           .imageurl!);
//                                                                 })
//                                                               : buildcontainer(
//                                                                   "View Details",
//                                                                   txt_color:
//                                                                       Colors
//                                                                           .blue,
//                                                                   onpressed:
//                                                                       () {
//                                                                   if (testBean!
//                                                                           .data![
//                                                                               i]
//                                                                           .status !=
//                                                                       null) {
//                                                                     if (testBean!
//                                                                             .data![i]
//                                                                             .status !=
//                                                                         "Completed") {
//                                                                       sendRoute(
//                                                                           context,
//                                                                           RoutesNames.complaint_detail,
//                                                                           data: {
//                                                                             'token':
//                                                                                 testBean!.data![i].token!
//                                                                           });
//                                                                     } else {
//                                                                       toast(
//                                                                           "Complaint is closed");
//                                                                     }
//                                                                   } else {
//                                                                     sendRoute(
//                                                                         context,
//                                                                         RoutesNames
//                                                                             .complaint_detail,
//                                                                         data: {
//                                                                           'token': testBean!
//                                                                               .data![i]
//                                                                               .token!
//                                                                         });
//                                                                   }
//                                                                 }),
//                       topLeftCornerWidget: Center(
//                         child: buildcontainer('S.No',
//                             isbold: true,
//                             isheader: true,
//                             txt_color: Colors.white),
//                       ),
//                     ),
//                   )
//                 : Container(),
//             SizedBox(
//               height: 20.h,
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   imagedialog(String url) {
//     bottomSheetDialog(
//       context: context,
//       dismissable: false,
//       content: StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//         return Container(
//           margin: EdgeInsets.only(top: 30.h),
//           padding:
//               EdgeInsets.only(top: 10.h, bottom: 20.h, left: 20.w, right: 20.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//           ),
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Stack(
//                     alignment: AlignmentDirectional.center,
//                     children: [
//                       Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               height: 500.h,
//                               child: PhotoView(
//                                 imageProvider: NetworkImage(
//                                   url,
//                                 ),
//                                 errorBuilder: (BuildContext context,
//                                     Object exception, StackTrace? stackTrace) {
//                                   return Image.asset(
//                                     Images.no_record_found,
//                                   );
//                                 },
//                               ),
//                             ),
//                             SizedBox(
//                               height: 5.h,
//                             ),
//                             CustomButtonWidget(
//                               'Done',
//                               height: 40.h,
//                               txt_size: 16.sp,
//                               bg_color: Colors.green,
//                               onpressed: () {
//                                 onbackpress(PrefUtil.navKey.currentContext!,
//                                     isdialog: true);
//                               },
//                             ),
//                           ]),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }
