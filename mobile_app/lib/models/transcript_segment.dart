class TranscriptSegment {
  final double? startTime;
  final double? endTime;
  final String pa;
  final String hi;
  final String en;
  final bool flagged;

  const TranscriptSegment({
    this.startTime,
    this.endTime,
    required this.pa,
    this.hi = '',
    this.en = '',
    this.flagged = false,
  });

  double get start => startTime ?? 0.0;
  double get end => endTime ?? 0.0;
  bool get isTimed => startTime != null;

  String forLanguage(String languageCode, {bool enableHindi = false, bool enableEnglish = false}) {
    if (languageCode == 'en' && enableEnglish && en.isNotEmpty) return en;
    if (languageCode == 'hi' && enableHindi && hi.isNotEmpty) return hi;
    return pa;
  }

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      startTime: (json['startTime'] as num?)?.toDouble() ?? (json['start'] as num?)?.toDouble(),
      endTime: (json['endTime'] as num?)?.toDouble() ?? (json['end'] as num?)?.toDouble(),
      pa: (json['pa'] ?? json['text'] ?? '') as String,
      hi: (json['hi'] ?? '') as String,
      en: (json['en'] ?? '') as String,
      flagged: (json['flagged'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'start': start,
      'end': end,
      'pa': pa,
      'hi': hi,
      'en': en,
      'flagged': flagged,
    };
  }
}
