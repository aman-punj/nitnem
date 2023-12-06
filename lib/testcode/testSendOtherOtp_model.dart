import 'dart:convert';
TestSendOtherOtpModel testSendOtherOtpModelFromJson(String str) => TestSendOtherOtpModel.fromJson(json.decode(str));
String testSendOtherOtpModelToJson(TestSendOtherOtpModel data) => json.encode(data.toJson());
class TestSendOtherOtpModel {
  TestSendOtherOtpModel({
      String? status, 
      String? msg, 
      String? data, 
      String? otp,}){
    _status = status;
    _msg = msg;
    _data = data;
    _otp = otp;
}

  TestSendOtherOtpModel.fromJson(dynamic json) {
    _status = json['status'];
    _msg = json['msg'];
    _data = json['Data'];
    _otp = json['otp'];
  }
  String? _status;
  String? _msg;
  String? _data;
  String? _otp;

  String? get status => _status;
  String? get msg => _msg;
  String? get data => _data;
  String? get otp => _otp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['msg'] = _msg;
    map['Data'] = _data;
    map['otp'] = _otp;
    return map;
  }

}