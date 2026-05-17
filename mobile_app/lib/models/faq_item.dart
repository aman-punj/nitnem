class FaqItem {
  final String id;
  final String question;
  final String answer;
  final int order;
  final bool enabled;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.order,
    required this.enabled,
  });

  factory FaqItem.fromMap(String id, Map<String, dynamic> map) {
    final dynamic orderRaw = map['order'];
    final dynamic enabledRaw = map['enabled'];

    return FaqItem(
      id: id,
      question: (map['question'] ?? '') as String,
      answer: (map['answer'] ?? '') as String,
      order: orderRaw is int ? orderRaw : int.tryParse('$orderRaw') ?? 0,
      enabled: enabledRaw is bool ? enabledRaw : '$enabledRaw'.toLowerCase() == 'true',
    );
  }
}
