import '../models/transcript_segment.dart';

class TranscriptSyncEngine {
  const TranscriptSyncEngine();

  int findSegmentIndexByTime(List<TranscriptSegment> segments, double seconds) {
    if (segments.isEmpty) return -1;

    var low = 0;
    var high = segments.length - 1;

    while (low <= high) {
      final mid = low + ((high - low) >> 1);
      final current = segments[mid];

      if (seconds >= current.start && seconds <= current.end) {
        return mid;
      }
      if (seconds < current.start) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    return -1;
  }
}
