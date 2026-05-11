class ContentCategory {
  const ContentCategory({
    required this.id,
    required this.title,
    this.iconKey,
    this.displayOrder = 100,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String? iconKey;
  final int displayOrder;
  final bool enabled;

  factory ContentCategory.fromMap(Map<String, dynamic> map) {
    return ContentCategory(
      id: map['id'] ?? 'uncategorized',
      title: map['title'] ?? 'Other Banis',
      iconKey: map['iconKey'],
      displayOrder: map['displayOrder'] ?? 100,
      enabled: map['enabled'] ?? true,
    );
  }
}
