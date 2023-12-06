// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../Utils/strings.dart';
// import '../data/model/testBean.dart';
// import '../data/network/service/api_service.dart';
//
//
// class TestBloc extends Bloc<TestEvent, TestState> {
//   TestRepository repository;
//
//   TestBloc({required this.repository}) : super(TestInitialState()) {
//     on<FetchTestsEvent>((event, emit) async {
//       emit(TestInitialState());
//       try {
//         TestBean Tests =
//         await repository.getTest(event.data);
//         if (Tests.status == null) {
//           if (Tests.data!.length>0) {
//             emit(TestLoadedState(Tests: Tests));
//           } else {
//             emit(TestErrorState(message: AppConstants.no_data_error));
//           }
//         } else {
//           if (Tests.status!.toLowerCase() == "success") {
//             emit(TestLoadedState(Tests: Tests));
//           } else if (Tests.status!.toLowerCase() == "close") {
//             emit(TestCloseState(message: Tests.msg!));
//           } else {
//             emit(TestErrorState(message: Tests.msg!));
//           }
//         }
//       } catch (e) {
//         emit(TestErrorState(message: e.toString()));
//       }
//     });
//   }
// }
//
// abstract class TestEvent extends Equatable {}
//
// class FetchTestsEvent extends TestEvent {
//   Map<String, dynamic>? data;
//
//   FetchTestsEvent(this.data);
//
//   @override
//   // TODO: implement props
//   List<Object?> get props => throw UnimplementedError();
// }
//
// abstract class TestState extends Equatable {}
//
// class TestInitialState extends TestState {
//   @override
//   // TODO: implement props
//   List<Object> get props => [];
// }
//
// class TestLoadingState extends TestState {
//   @override
//   // TODO: implement props
//   List<Object> get props => [];
// }
//
// class TestLoadedState extends TestState {
//   TestBean Tests;
//
//   TestLoadedState({required this.Tests});
//
//   @override
//   // TODO: implement props
//   List<Object> get props => [Tests];
// }
//
// class TestErrorState extends TestState {
//   String message;
//
//   TestErrorState({required this.message});
//
//   @override
//   // TODO: implement props
//   List<Object> get props => [message];
// }
//
// class TestCloseState extends TestState {
//   String message;
//
//   TestCloseState({required this.message});
//
//   @override
//   // TODO: implement props
//   List<Object> get props => [message];
// }
//
// abstract class TestRepository {
//   Future<TestBean> getTest(Map<String, dynamic>? data);
// }
//
// class TestRepositoryImpl implements TestRepository {
//   @override
//   Future<TestBean> getTest(Map<String, dynamic>? data) async {
//
//     final Response response = await ApiService().post(
//       AppConstants.TestList,
//       data: data,
//     );
//     if (response.statusCode == 200) {
//       var data = json.decode('$response');
//       TestBean bean =
//       TestBean.fromJson(data);
//       return bean;
//     } else {
//       throw Exception();
//     }
//   }
// }