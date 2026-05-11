import 'dart:convert';

import '../models/transcript_segment.dart';

class TranscriptParser {
  static List<TranscriptSegment> parseLrc(String lrc, {List<String>? hiLines, List<String>? enLines}) {
    final matches =
        RegExp(r'^\[(\d{2}):(\d{2}\.\d{1,3})\](.*)$', multiLine: true)
            .allMatches(lrc);
    final raw = <Map<String, dynamic>>[];

    for (final match in matches) {
      final minute = int.parse(match.group(1)!);
      final second = double.parse(match.group(2)!);
      final text = (match.group(3) ?? '').trim();
      raw.add({'start': (minute * 60) + second, 'pa': text});
    }

    final segments = <TranscriptSegment>[];
    for (var i = 0; i < raw.length; i++) {
      final current = raw[i];
      final start = current['start'] as double;
      final end = i + 1 < raw.length ? raw[i + 1]['start'] as double : start + 6;
      segments.add(
        TranscriptSegment(
          startTime: start,
          endTime: end,
          pa: current['pa'] as String,
          hi: (hiLines != null && i < hiLines.length) ? hiLines[i] : '',
          en: (enLines != null && i < enLines.length) ? enLines[i] : '',
        ),
      );
    }

    return segments;
  }

  static List<TranscriptSegment> parseJsonString(String content) {
    final decoded = jsonDecode(content);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TranscriptSegment.fromJson)
          .toList(growable: false);
    }

    final map = decoded as Map<String, dynamic>;
    final segments = (map['segments'] as List<dynamic>? ?? const []);
    return segments
        .whereType<Map<String, dynamic>>()
        .map(TranscriptSegment.fromJson)
        .toList(growable: false);
  }

  static Map<String, dynamic> toLegacyJson(List<TranscriptSegment> segments) {
    return {'segments': segments.map((e) => e.toJson()).toList(growable: false)};
  }
}
