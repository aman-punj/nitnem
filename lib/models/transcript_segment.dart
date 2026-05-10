class TranscriptSegment {
  final double start;
  final double end;
  final String pa;
  final String hi;
  final String en;
  final bool flagged;

  const TranscriptSegment({
    required this.start,
    required this.end,
    required this.pa,
    this.hi = '',
    this.en = '',
    this.flagged = false,
  });

  String forLanguage(String languageCode, {bool enableHindi = false, bool enableEnglish = false}) {
    if (languageCode == 'en' && enableEnglish && en.isNotEmpty) return en;
    if (languageCode == 'hi' && enableHindi && hi.isNotEmpty) return hi;
    return pa;
  }

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      start: (json['start'] as num?)?.toDouble() ?? 0.0,
      end: (json['end'] as num?)?.toDouble() ?? 0.0,
      pa: (json['pa'] ?? json['text'] ?? '') as String,
      hi: (json['hi'] ?? '') as String,
      en: (json['en'] ?? '') as String,
      flagged: (json['flagged'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'pa': pa,
      'hi': hi,
      'en': en,
      'flagged': flagged,
    };
  }
}
