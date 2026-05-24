class DeveloperSupport {
  final String upiId;
  final String upiQrUrl;
  final String kofiUrl;

  const DeveloperSupport({
    required this.upiId,
    required this.upiQrUrl,
    required this.kofiUrl,
  });

  factory DeveloperSupport.fromMap(Map<String, dynamic> map) {
    return DeveloperSupport(
      upiId: map['upiId'] as String? ?? '',
      upiQrUrl: map['upiQrUrl'] as String? ?? '',
      kofiUrl: map['kofiUrl'] as String? ?? '',
    );
  }

  bool get hasUpi => upiId.isNotEmpty || upiQrUrl.isNotEmpty;
  bool get hasKofi => kofiUrl.isNotEmpty;
  bool get isConfigured => hasUpi || hasKofi;
}
