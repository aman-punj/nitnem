import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Model for a single transcript segment
class TranscriptSegment {
  final double start;
  final double end;
  final String text;

  TranscriptSegment({required this.start, required this.end, required this.text});

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      start: json['start']?.toDouble() ?? 0.0,
      end: json['end']?.toDouble() ?? 0.0,
      text: json['text'] ?? '',
    );
  }
}

/// Responsible for loading and parsing the transcript
class TranscriptService {
  Future<List<TranscriptSegment>> loadTranscript(String path) async {
    final jsonStr = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonData = json.decode(jsonStr);
    final List<dynamic> segments = jsonData['segments'] ?? [];
    return segments.map((s) => TranscriptSegment.fromJson(s)).toList();
  }
}

/// Audio controller for playback logic
class AudioController {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> loadAudio(String assetPath) async {
    await _player.setAsset(assetPath);
  }

  void dispose() {
    _player.dispose();
  }
}

/// PrayerPage accepts audio & transcript paths dynamically
class PrayerPage extends StatefulWidget {
  final String title;
  final String audioAssetPath;
  final String transcriptAssetPath;

  const PrayerPage({
    super.key,
    required this.title,
    required this.audioAssetPath,
    required this.transcriptAssetPath,
  });

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  final AudioController _audioController = AudioController();
  final TranscriptService _transcriptService = TranscriptService();
  List<TranscriptSegment> _segments = [];
  int _currentSegmentIndex = -1;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _segments = await _transcriptService.loadTranscript(widget.transcriptAssetPath);
    await _audioController.loadAudio(widget.audioAssetPath);
    _audioController.player.positionStream.listen(_updateLyrics);
    setState(() {});
  }

  void _updateLyrics(Duration position) {
    final seconds = position.inMilliseconds / 1000.0;
    final index = _segments.indexWhere((s) => seconds >= s.start && seconds <= s.end);
    if (index != _currentSegmentIndex && index != -1) {
      setState(() {
        _currentSegmentIndex = index;
      });
    }
  }

  void _togglePlayback() async {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_audioController.player.playing) {
      await _audioController.player.pause();
    } else {
      await _audioController.player.play();
    }
  }

  @override
  void dispose() {
    _audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: _segments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _segments.length,
              itemBuilder: (context, index) {
                final segment = _segments[index];
                final isHighlighted = index == _currentSegmentIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    segment.text,
                    style: TextStyle(
                      color: isHighlighted ? Colors.amber : Colors.white70,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),
          ),
          StreamBuilder<Duration>(
            stream: _audioController.player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = _audioController.player.duration ?? Duration.zero;

              return Column(
                children: [
                  Slider(
                    activeColor: Colors.amber,
                    inactiveColor: Colors.white24,
                    min: 0,
                    max: total.inMilliseconds.toDouble(),
                    value: position.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                    onChanged: (value) {
                      _audioController.player.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position), style: const TextStyle(color: Colors.white70)),
                        Text(_formatDuration(total), style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 48,
              color: Colors.white,
            ),
            onPressed: _togglePlayback,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
