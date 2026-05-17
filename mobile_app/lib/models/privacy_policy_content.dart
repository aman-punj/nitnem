class PrivacyPolicyContent {
  final String title;
  final String content;

  const PrivacyPolicyContent({required this.title, required this.content});

  factory PrivacyPolicyContent.fromMap(Map<String, dynamic> map) {
    return PrivacyPolicyContent(
      title: (map['title'] ?? 'Privacy Policy') as String,
      content: (map['content'] ?? '') as String,
    );
  }
}
