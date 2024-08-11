import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class PrayerPage extends StatefulWidget {
  final String prayerText;
  final String prayerName;
  final int num;

  PrayerPage({
    Key? key,
    required this.prayerText,
    required this.prayerName,
    required this.num,
  }) : super(key: key);

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  int fontSize = 20;
  int currentIndex = -1;
  List<Map<String, dynamic>> parsedLyrics = [];
  final player = AudioPlayer();
  bool isPlaying = false;
  late Timer positionTimer;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    loadLyrics();
    player.onDurationChanged.listen((Duration newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    positionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      updatePosition();
    });
  }

  @override
  void dispose() {
    positionTimer.cancel();
    player.dispose();
    super.dispose();
  }

  void incrs() {
    setState(() {
      fontSize++;
    });
  }

  void decres() {
    setState(() {
      fontSize--;
    });
  }

  void loadLyrics() async {
    try {
      String lyricsContent = await rootBundle.loadString('assets/audios/chaupai_sahib_text.lrc');
      parsedLyrics = parseLrc(lyricsContent);
      print('Lyrics Loaded: $parsedLyrics');
    } catch (e) {
      print('Error loading lyrics: $e');
    }
  }

  List<Map<String, dynamic>> parseLrc(String content) {
    List<Map<String, dynamic>> result = [];
    List<String> lines = LineSplitter.split(content).toList();
    RegExp regExp = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)');

    for (String line in lines) {
      Iterable<RegExpMatch> matches = regExp.allMatches(line);
      for (RegExpMatch match in matches) {
        int minutes = int.parse(match.group(1)!);
        double seconds = double.parse(match.group(2)!);
        String text = match.group(3)!.trim();
        Duration time = Duration(
          minutes: minutes,
          seconds: seconds.floor(),
          milliseconds: ((seconds - seconds.floor()) * 1000).toInt(),
        );
        result.add({'time': time, 'text': text});
      }
    }
    return result;
  }

  void updatePosition() async {
    Duration? pos = await player.getCurrentPosition();
    if (pos != null) {
      setState(() {
        position = pos;
        updateLyricsPosition(pos);
      });
    }
  }

  void updateLyricsPosition(Duration position) {
    for (int i = 0; i < parsedLyrics.length; i++) {
      Duration lyricTime = parsedLyrics[i]['time'];
      if (position >= lyricTime) {
        currentIndex = i;
      } else {
        break;
      }
    }
    print('Current Index: $currentIndex'); // Debugging line
  }

  Future<void> playSound() async {
    String soundPath = "audios/audio${widget.num}.mp3";
    await player.play(AssetSource(soundPath));
    setState(() {
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prayerName),
        backgroundColor: Colors.grey[700],
        actions: [
          Row(
            children: [
              IconButton(onPressed: incrs, icon: const Icon(Icons.zoom_in)),
              IconButton(onPressed: decres, icon: const Icon(Icons.zoom_out)),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.h),
          child: Column(
            children: [
              // Container(
              //   width: 1.sw,
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFcccccc),
              //     border: Border.all(color: Colors.black),
              //     borderRadius: BorderRadius.circular(8.0),
              //   ),
              //   padding: EdgeInsets.all(16.0.h),
              //   child: Text(
              //     widget.prayerText,
              //     style: TextStyle(fontSize: fontSize.sp, color: Colors.black),
              //   ),
              // ),
              SizedBox(height: 16.0.h),
              if (parsedLyrics.isNotEmpty && currentIndex >= 0)
                Text(
                  parsedLyrics[currentIndex]['text'],
                  style: TextStyle(fontSize: fontSize.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60.h,
        width: 1.sw,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              child: Center(
                child: Text(
                  formatDuration(position),
                  style: TextStyle(fontSize: 18.sp, color: Colors.black),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                if (isPlaying) {
                  await player.pause();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await playSound();
                }
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8.0.w), // Adjust the spacing as needed
                    Text(
                      isPlaying ? 'Pause' : 'Play',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              child: Center(
                child: Text(
                  formatDuration(duration - position),
                  style: TextStyle(fontSize: 18.sp, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
