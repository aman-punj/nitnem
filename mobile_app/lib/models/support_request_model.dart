class SupportRequestModel {
  final String type;
  final String title;
  final String message;
  final String email;
  final String appVersion;
  final String buildNumber;
  final String platform;
  final String status;

  const SupportRequestModel({
    required this.type,
    required this.title,
    required this.message,
    required this.email,
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    this.status = 'new',
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'email': email,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'platform': platform,
      'status': status,
    };
  }
}
