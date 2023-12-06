// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gpayapp/Bloc/PincodeBloc.dart';
// import 'package:gpayapp/Bloc/VerifyOtherOtpBloc.dart';
// import 'package:gpayapp/Bloc/VerifyOtpBloc.dart';
// import 'package:gpayapp/Utils/CustomButtonWidget.dart';
// import 'package:gpayapp/Utils/CustomTextWidget.dart';
// import 'package:gpayapp/Utils/colors.dart';
// import 'package:gpayapp/Utils/common_widget.dart';
// import 'package:gpayapp/data/model/PincodeBean.dart';
//
// import '../Bloc/CheckIdBloc.dart';
// import '../Bloc/TestBloc.dart';
// import '../Bloc/Test_SendOtherOtpBloc.dart';
// import '../Utils/strings.dart';
// import '../main.dart';
// import '../routes/route.dart';
//
// class TestRegistrationForm extends StatefulWidget {
//   const TestRegistrationForm({super.key});
//
//   @override
//   State<TestRegistrationForm> createState() => _TestRegistrationFormState();
// }
//
// class _TestRegistrationFormState extends State<TestRegistrationForm> {
//   final _mobileformKey = GlobalKey<FormState>();
//   final _otpformKey = GlobalKey<FormState>();
//   final _sponserKey = GlobalKey<FormState>();
//
//   VerifyOtherOtpBloc? verifyOtherOtp;
//   PincodeBloc? pincodeBloc;
//   PincodeBean? pincodeBean;
//   TestSendOtherOtpBloc? testSendotpBloc;
//   CheckIdBloc? checkIdBloc;
//
//   TextEditingController number_controller = TextEditingController();
//   TextEditingController otp_controller = TextEditingController();
//   TextEditingController sponsor_controller = TextEditingController();
//   TextEditingController sponsorName_controller = TextEditingController();
//   TextEditingController frenchiseName_controller = TextEditingController();
//   TextEditingController ownerName_controller = TextEditingController();
//   TextEditingController alternateMobileNumber_controller =
//       TextEditingController();
//   TextEditingController address_controller = TextEditingController();
//   TextEditingController pincode_controller = TextEditingController();
//   TextEditingController area_controller = TextEditingController();
//   TextEditingController city_controller = TextEditingController();
//   TextEditingController state_controller = TextEditingController();
//   TextEditingController branch_name_controller = TextEditingController();
//   TextEditingController ifsc_controller = TextEditingController();
//
//   LoadingDialog? pr;
//   int form_step = 1;
//
//   bool mobile_enable = true, sponsor_enable = true;
//
//   List<String> area_list = ["Select area"], bank_list = ['Select bank'];
//
//   String _selectedarea = 'Select area', _selectedbank = 'Select bank';
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
//     testSendotpBloc = BlocProvider.of<TestSendOtherOtpBloc>(context);
//     verifyOtherOtp = BlocProvider.of<VerifyOtherOtpBloc>(context);
//     checkIdBloc = BlocProvider.of<CheckIdBloc>(context);
//     pincodeBloc = BlocProvider.of<PincodeBloc>(context);
//
//     // pincodeBloc = BlocProvider.of<PincodeBloc>(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         // these are state of the app which can/will occur
//         BlocListener<TestSendOtherOtpBloc, TestSendOtherOtpState>(
//           listener: (context, state) {
//             if (state is TestSendOtherOtpInitialState) {
//               pr!.show();
//             } else if (state is TestSendOtherOtpLoadingState) {
//               pr!.show();
//             } else if (state is TestSendOtherOtpErrorState) {
//               pr!.dismiss();
//               print('error happened${state.message}');
//               Custom_Dialog(mcontext: context, message: state.message).show();
//             } else if (state is TestSendOtherOtpCloseState) {
//               pr!.dismiss();
//               print(state.message);
//               Custom_Dialog(
//                   mcontext: context,
//                   message: state.message,
//                   positive_btn_text: 'proceed',
//                   onpress: () {
//                     sendRoute(
//                         PrefUtil.navKey.currentContext!, RoutesNames.welcome,
//                         clearstack: true);
//                   }).show();
//             } else if (state is TestSendOtherOtpLoadedState) {
//               pr!.dismiss();
//               toast('OTP Sent');
//               setState(() {
//                 mobile_enable = false;
//               });
//             }
//           },
//         ),
//         BlocListener<VerifyOtherOtpBloc, VerifyOtherOtpState>(
//             listener: (context, state) async {
//           if (state is VerifyOtherOtpErrorState) {
//             print('Error ${state.message}');
//             Custom_Dialog(
//                     message: state.message,
//                     mcontext: context,
//                     positive_btn_text: 'OK')
//                 .show();
//             pr!.dismiss();
//           } else if (state is VerifyOtherOtpCloseState) {
//             print('closing otp ${state.message}');
//             Custom_Dialog(
//                 message: state.message,
//                 mcontext: context,
//                 positive_btn_text: 'Proceed',
//                 dismissable: false,
//                 isClose: true,
//                 onpress: () {
//                   sendRoute(
//                       PrefUtil.navKey.currentContext!, RoutesNames.welcome,
//                       clearstack: true);
//                 }).show();
//           } else if (state is VerifyOtherOtpInitialState) {
//             pr!.show();
//           } else if (state is VerifyOtherOtpLoadingState) {
//             pr!.show();
//           } else if (state is VerifyOtherOtpLoadedState) {
//             pr!.dismiss();
//             setState(() {
//               form_step++;
//             });
//           }
//         }),
//         BlocListener<PincodeBloc, PincodeState>(
//             listener: (context, state) async {
//           if (state is PincodeErrorState) {
//             pr!.dismiss();
//             debugPrint(state.message);
//             Custom_Dialog(
//                     mcontext: context,
//                     message: state.message,
//                     positive_btn_text: "OK")
//                 .show();
//           } else if (state is PincodeCloseState) {
//             pr!.dismiss();
//             debugPrint(state.message);
//             Custom_Dialog(
//                 mcontext: context,
//                 message: state.message,
//                 positive_btn_text: "Proceed",
//                 dismissable: false,
//                 isClose: true,
//                 onpress: () {
//                   sendRoute(
//                       PrefUtil.navKey.currentContext!, RoutesNames.welcome,
//                       clearstack: true);
//                 }).show();
//           } else if (state is PincodeInitialState) {
//             pr!.show();
//           } else if (state is PincodeLoadingState) {
//             pr!.show();
//           } else if (state is PincodeLoadedState) {
//             pr!.dismiss();
//
//             ///+++++++++++++++++  understand this  +++++++++++++++++
//             setState(() {
//               pincodeBean = state.Pincodes;
//               if (pincodeBean!.data!.isNotEmpty) {
//                 area_list = [];
//                 area_list.add("Select area");
//                 for (int i = 0; i < pincodeBean!.data!.length; i++) {
//                   area_list.add(pincodeBean!.data![i].area!);
//                 }
//
//                 //   if (checkString(PrefUtil.getreg()!.rows![0].area, isempty: true)
//                 //       .isNotEmpty) {
//                 //     if (area_list.contains(PrefUtil.getreg()!.rows![0].area!)) {
//                 //       _selectedarea = PrefUtil.getreg()!.rows![0].area!;
//                 //       city_controller.text = checkString(
//                 //           PrefUtil.getreg()!.rows![0].city,
//                 //           isempty: true);
//                 //       state_controller.text = checkString(
//                 //           PrefUtil.getreg()!.rows![0].state,
//                 //           isempty: true);
//                 //     }
//                 //   }
//                 // } else {
//                 //   pincode_controller.text = "";
//               }
//             });
//           }
//         }),
//         BlocListener<CheckIdBloc, CheckIdState>(
//           listener: (context, state) async {
//             if (state is CheckIdErrorState) {
//               pr!.dismiss();
//               debugPrint(state.message);
//               Custom_Dialog(
//                       mcontext: context,
//                       message: state.message,
//                       positive_btn_text: "OK")
//                   .show();
//               setState(() {
//                 sponsor_controller.text = "";
//                 sponsorName_controller.text = "";
//                 sponsor_enable = false;
//               });
//             } else if (state is CheckIdCloseState) {
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
//             } else if (state is CheckIdInitialState) {
//               pr!.show();
//             } else if (state is CheckIdLoadingState) {
//               pr!.show();
//             } else if (state is CheckIdLoadedState) {
//               pr!.dismiss();
//               setState(() {
//                 sponsorName_controller.text = state.CheckIds.data!;
//                 sponsor_enable = false;
//               });
//             }
//           },
//         ),
//       ],
//       child: Scaffold(
//         // resizeToAvoidBottomInset: true,
//
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Container(
//                       alignment: Alignment.center,
//                       height: 40,
//                       width: 40,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.grey,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Center(
//                           child: Icon(
//                         Icons.arrow_back_ios_outlined,
//                         size: 16,
//                       )),
//                     ),
//                     CustomTextWidget(
//                       "Franchise Registration",
//                       isbold: true,
//                       size_txt: 22,
//                     ),
//                   ],
//                 ),
//
//                 // CustomTextWidget('Mobile'),
//                 Expanded(
//                     child: SingleChildScrollView(
//                         child: form_step == 1 ? firstForm() : secondForm()))
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Container secondForm() {
//     return Container(
//       margin: EdgeInsets.all(10.h),
//       child: Column(
//         // crossAxisAlignment: CrossAxisAlignment.center,
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Form(
//             key: _sponserKey,
//             child: text_form_field(
//               "Sponsor ID",
//               sponsor_controller,
//               // isenabled: sponsor_enable,  this will be in set state for sponsor id once set can't change until form is filled again
//               txt_color: Colors.black,
//               validator: (value) {
//                 if (value!.isEmpty) {
//                   return "Enter Sponsor ID";
//                 }
//                 // else if (value == PrefUtil.getreg()!.rows![0].memberId) {
//                 //   return "Enter a different Sponsor ID than yours.";
//                 // }
//                 return null;
//               },
//               suffix_icon_padded: false,
//               suffix_icon: InkWell(
//                 onTap: () {
//                   if (_sponserKey.currentState!.validate()) {
//                     checkIdBloc!.add(FetchCheckIdsEvent(
//                         {"Id": sponsor_controller.text.toString()}));
//                   }
//                 },
//                 child: Container(
//                   height: 20.h,
//                   width: 20.w,
//                   decoration: BoxDecoration(
//                       color: ColorResources.pinkDB4,
//                       borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(5),
//                           bottomRight: Radius.circular(5))),
//                   child: Icon(
//                     Icons.chevron_right,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10.h,
//           ),
//           Form(
//               child: Column(
//             children: [
//               text_form_field(
//                 'Sponsor Name',
//                 sponsorName_controller,
//                 isenabled: false,
//                 isfilled: true,
//                 txt_color: ColorResources.black,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "Enter Sponsor Name";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(
//                 height: 20.h,
//               ),
//               text_form_field(
//                 "Franchise Name",
//                 frenchiseName_controller,
//                 textInputType: TextInputType.name,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "Enter Franchise Name";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               text_form_field(
//                 "Owner Name",
//                 ownerName_controller,
//                 textInputType: TextInputType.name,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "Enter Owner Name";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               text_form_field(
//                 "Alternate Mobile No.",
//                 alternateMobileNumber_controller,
//                 textInputType: TextInputType.phone,
//                 max_length: 10,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "Enter Alternate Mobile No.";
//                   } else if (value.length < 10) {
//                     return "Enter a valid Alternate Mobile No.";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               text_form_field(
//                 "Address",
//                 address_controller,
//                 textInputType: TextInputType.streetAddress,
//                 max_length: 10,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "Enter address";
//                   } else {
//                     return null;
//                   }
//                 },
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               Row(
//                 children: [
//                   Flexible(
//                     child: text_form_field(
//                       "Pincode",
//                       pincode_controller,
//                       textInputType: TextInputType.number,
//                       max_length: 6,
//                       onChanged: (value) {
//                         if (value.length == 6) {
//                           pincodeBloc!
//                               .add(FetchPincodesEvent({"pincode": value}));
//                         } else {
//                           state_controller.text = "";
//                           city_controller.text = "";
//                           _selectedarea = "Select area";
//                         }
//                       },
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Enter Pincode";
//                         } else if (value.length < 6) {
//                           return "Enter a valid Pincode";
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     width: 10.w,
//                   ),
//                   Flexible(
//                     child:
//                         builddropdown(context, area_list, _selectedarea, 'Area',
//                             onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedarea = newValue!;
//                         for (var i = 0; i < pincodeBean!.data!.length; i++) {
//                           if (pincodeBean!.data![i].area == _selectedarea) {
//                             city_controller.text =
//                                 pincodeBean!.data![i].districtname!;
//                             state_controller.text =
//                                 pincodeBean!.data![i].statename!;
//                           }
//                         }
//                       });
//                     }, validator: (value) {
//                       if (value == null) {
//                         return "Please select a area";
//                       } else if (value.toString() == 'Select area' ||
//                           value.toString() == "area") {
//                         return "Please select a area";
//                       } else {
//                         return null;
//                       }
//                     }),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               Row(
//                 children: [
//                   Flexible(
//                     child: text_form_field(
//                       "City",
//                       city_controller,
//                       isenabled: false,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Enter City";
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     width: 10.w,
//                   ),
//                   Flexible(
//                     child: text_form_field(
//                       "State",
//                       state_controller,
//                       isenabled: false,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Enter State";
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               builddropdown(
//                 context,
//                 bank_list,
//                 _selectedbank,
//                 'Bank Name',
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedbank = newValue!;
//                   });
//                 },
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               text_form_field(
//                 "Branch Name",
//                 branch_name_controller,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "Enter Branch Name";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               Row(
//                 children: [
//                   Flexible(
//                       child: text_form_field(
//                     'IFSC code',
//                     ifsc_controller,
//                     textCapitalization: TextCapitalization.characters,
//                     max_length: 11,
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return "Enter IFSC Code";
//                           } else if (value.length < 11) {
//                             return "Enter a valid IFSC Code";
//                           }
//                           return null;
//                         },))
//                 ],
//               )
//             ],
//           ))
//         ],
//       ),
//     );
//   }
//
//   Container firstForm() {
//     return Container(
//       margin: EdgeInsets.all(10.h),
//       child: Column(
//         children: [
//           SizedBox(
//             height: 50.h,
//           ),
//           Form(
//             key: _mobileformKey,
//             child: Row(
//               children: [
//                 Expanded(
//                     child: text_form_field('Mobile', number_controller,
//                         isenabled: mobile_enable,
//                         max_length: 10, validator: (number) {
//                   if (number!.isEmpty) {
//                     return 'Enter  Number';
//                   } else if (number.length < 10) {
//                     return 'Enter a valid mobile Number';
//                   } else {
//                     return null;
//                   }
//                 }, textInputType: TextInputType.number)),
//                 CustomButtonWidget(
//                   'Get OTP',
//                   bg_color: ColorResources.pinkDB4,
//                   txt_size: 14,
//                   onpressed: () {
//                     if (_mobileformKey.currentState!.validate()) {
//                       testSendotpBloc!.add(FetchTestSendOtherOtpsEvent({
//                         "mobileno": number_controller.text.toString(),
//                         "name": ""
//                       }));
//                       // toast('this is for validation');
//                       // mobile_enable = false;
//                     }
//                   },
//                 )
//               ],
//             ),
//           ),
//           !mobile_enable
//               ? Form(
//                   key: _otpformKey,
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 20.h,
//                       ),
//                       text_form_field(
//                         'OTP Sent',
//                         otp_controller,
//                         textInputType: TextInputType.number,
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return "Enter OTP";
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(
//                         height: 20.h,
//                       ),
//                       CustomButtonWidget(
//                         'Proceed',
//                         onpressed: () {
//                           if (_otpformKey.currentState!.validate()) {
//                             verifyOtherOtp!.add(FetchVerifyOtherOtpsEvent({
//                               "otp": otp_controller.text.toString(),
//                               "mobileno": number_controller.text.toString()
//                             }));
//                           }
//                         },
//                       )
//                     ],
//                   ))
//               : Container()
//         ],
//       ),
//     );
//   }
// }
