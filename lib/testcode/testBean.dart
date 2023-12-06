import 'dart:convert';
TestBean testBeanFromJson(String str) => TestBean.fromJson(json.decode(str));
String testBeanToJson(TestBean data) => json.encode(data.toJson());
class TestBean {
  TestBean({
      String? status, 
      String? msg, 
      List<Data>? data,}){
    _status = status;
    _msg = msg;
    _data = data;
}

  TestBean.fromJson(dynamic json) {
    _status = json['status'];
    _msg = json['msg'];
    if (json['Data'] != null) {
      _data = [];
      json['Data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  String? _status;
  String? _msg;
  List<Data>? _data;

  String? get status => _status;
  String? get msg => _msg;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['msg'] = _msg;
    if (_data != null) {
      map['Data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      num? id, 
      String? token, 
      String? complain, 
      String? comdate, 
      String? status, 
      String? replay, 
      String? repdate, 
      String? mobileno, 
      String? email, 
      String? nature, 
      String? subject, 
      String? imageurl,}){
    _id = id;
    _token = token;
    _complain = complain;
    _comdate = comdate;
    _status = status;
    _replay = replay;
    _repdate = repdate;
    _mobileno = mobileno;
    _email = email;
    _nature = nature;
    _subject = subject;
    _imageurl = imageurl;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _token = json['token'];
    _complain = json['complain'];
    _comdate = json['comdate'];
    _status = json['status'];
    _replay = json['replay'];
    _repdate = json['repdate'];
    _mobileno = json['mobileno'];
    _email = json['email'];
    _nature = json['nature'];
    _subject = json['subject'];
    _imageurl = json['imageurl'];
  }
  num? _id;
  String? _token;
  String? _complain;
  String? _comdate;
  String? _status;
  String? _replay;
  String? _repdate;
  String? _mobileno;
  String? _email;
  String? _nature;
  String? _subject;
  String? _imageurl;

  num? get id => _id;
  String? get token => _token;
  String? get complain => _complain;
  String? get comdate => _comdate;
  String? get status => _status;
  String? get replay => _replay;
  String? get repdate => _repdate;
  String? get mobileno => _mobileno;
  String? get email => _email;
  String? get nature => _nature;
  String? get subject => _subject;
  String? get imageurl => _imageurl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['token'] = _token;
    map['complain'] = _complain;
    map['comdate'] = _comdate;
    map['status'] = _status;
    map['replay'] = _replay;
    map['repdate'] = _repdate;
    map['mobileno'] = _mobileno;
    map['email'] = _email;
    map['nature'] = _nature;
    map['subject'] = _subject;
    map['imageurl'] = _imageurl;
    return map;
  }

}