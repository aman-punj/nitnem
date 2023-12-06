// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../Utils/strings.dart';
// import '../data/model/TestSendOtherOtp_model.dart';
// import '../data/network/service/api_service.dart';
//
//
// class TestSendOtherOtpBloc extends Bloc<TestSendOtherOtpEvent, TestSendOtherOtpState> {
//   TestSendOtherOtpRepository repository;
//
//   TestSendOtherOtpBloc({required this.repository}) : super(TestSendOtherOtpInitialState()) {
//     on<FetchTestSendOtherOtpsEvent>((event, emit) async {
//       emit(TestSendOtherOtpInitialState());
//       try {
//         TestSendOtherOtpModel TestSendOtherOtps =
//         await repository.getTestSendOtherOtp(event.data);
//         if (TestSendOtherOtps.status == null) {
//           if (TestSendOtherOtps.data! == "Success") {
//             emit(TestSendOtherOtpLoadedState(TestSendOtherOtps: TestSendOtherOtps));
//           } else {
//             emit(TestSendOtherOtpErrorState(message: TestSendOtherOtps.data!));
//           }
//         } else {
//           if (TestSendOtherOtps.status!.toLowerCase() == "success") {
//             emit(TestSendOtherOtpLoadedState(TestSendOtherOtps: TestSendOtherOtps));
//           } else if (TestSendOtherOtps.status!.toLowerCase() == "close") {
//             emit(TestSendOtherOtpCloseState(message: TestSendOtherOtps.msg!));
//           } else {
//             emit(TestSendOtherOtpErrorState(message: TestSendOtherOtps.msg!));
//           }
//         }
//       } catch (e) {
//         emit(TestSendOtherOtpErrorState(message: e.toString()));
//       }
//     });
//   }
// }
//
// abstract class TestSendOtherOtpEvent extends Equatable {}
//
// class FetchTestSendOtherOtpsEvent extends TestSendOtherOtpEvent {
//   Map<String, dynamic>? data;
//
//   FetchTestSendOtherOtpsEvent(this.data);
//
//   @override
//   // TODO: implement props
//   List<Object?> get props => throw UnimplementedError();
// }
//
// abstract class TestSendOtherOtpState extends Equatable {}
//
// class TestSendOtherOtpInitialState extends TestSendOtherOtpState {
//   @override
//   // TODO: implement props
//   List<Object> get props => [];
// }
//
// class TestSendOtherOtpLoadingState extends TestSendOtherOtpState {
//   @override
//   // TODO: implement props
//   List<Object> get props => [];
// }
//
// class TestSendOtherOtpLoadedState extends TestSendOtherOtpState {
//   TestSendOtherOtpModel TestSendOtherOtps;
//
//   TestSendOtherOtpLoadedState({required this.TestSendOtherOtps});
//
//   @override
//   // TODO: implement props
//   List<Object> get props => [TestSendOtherOtps];
// }
//
// class TestSendOtherOtpErrorState extends TestSendOtherOtpState {
//   String message;
//
//   TestSendOtherOtpErrorState({required this.message});
//
//   @override
//   // TODO: implement props
//   List<Object> get props => [message];
// }
//
// class TestSendOtherOtpCloseState extends TestSendOtherOtpState {
//   String message;
//
//   TestSendOtherOtpCloseState({required this.message});
//
//   @override
//   // TODO: implement props
//   List<Object> get props => [message];
// }
//
// abstract class TestSendOtherOtpRepository {
//   Future<TestSendOtherOtpModel> getTestSendOtherOtp(Map<String, dynamic>? data);
// }
//
// class TestSendOtherOtpRepositoryImpl implements TestSendOtherOtpRepository {
//   @override
//   Future<TestSendOtherOtpModel> getTestSendOtherOtp(Map<String, dynamic>? data) async {
//
//     // final Response response = await ApiService().post(
//     //   AppConstants.TestSendOtherOtpModel,
//     //   data: data,
//     // );
//     // if (response.statusCode == 200) {
//       //var data = json.decode('$response');
//     var data = json.decode('{"Data":"Success","otp":"2547"}');
//       TestSendOtherOtpModel bean =
//       TestSendOtherOtpModel.fromJson(data);
//       return bean;
//     // } else {
//     //   throw Exception();
//     // }
//   }
// }