class HukamnamaModel {
  final String date;
  final String gurmukhi;
  final String translationEnglish;
  final String translationPunjabi;
  final String source;

  const HukamnamaModel({
    required this.date,
    required this.gurmukhi,
    required this.translationEnglish,
    required this.translationPunjabi,
    required this.source,
  });

  factory HukamnamaModel.fromMap(Map<String, dynamic> map) {
    return HukamnamaModel(
      date: map['date'] as String? ?? '',
      gurmukhi: map['gurmukhi'] as String? ?? '',
      translationEnglish: map['translationEnglish'] as String? ?? '',
      translationPunjabi: map['translationPunjabi'] as String? ?? '',
      source: map['source'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'gurmukhi': gurmukhi,
      'translationEnglish': translationEnglish,
      'translationPunjabi': translationPunjabi,
      'source': source,
    };
  }
}
