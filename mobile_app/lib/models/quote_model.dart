class QuoteModel {
  final String text;
  final String? author;

  const QuoteModel({required this.text, this.author});

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    return QuoteModel(
      text: (map['text'] as String?) ?? '',
      author: ((map['author'] as String?) ?? '').trim().isEmpty ? null : (map['author'] as String).trim(),
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        if (author != null) 'author': author,
      };
}
