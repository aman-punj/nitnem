import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class PrayerPage extends StatefulWidget {
  final String prayerText;
  String prayerName;
  int num;

  PrayerPage(
      {Key? key,
      required this.prayerText,
      required this.prayerName,
      required this.num,
      String? title})
      : super(key: key);

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  int fontSize = 20;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   player.onPlayerStateChanged.listen((state) { })
  // }

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

  final player = AudioPlayer();

  bool isPlaying = false;

  late Timer positionTimer;

  @override
  void initState() {
    super.initState();
    player.onDurationChanged.listen((Duration newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    positionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        player.getCurrentPosition().then((Duration? value) {
          if (value != null) {
            position = value;
          }
        });
      });
    });
  }

  @override
  void dispose() {
    positionTimer.cancel();
    player.dispose();
    super.dispose();
  }

  Duration duration = Duration.zero;

  Duration position = Duration.zero;

  Future<void> playSound() async {
    String soundPath = "audios/audio${widget.num}.mp3";
    await player.play(AssetSource(soundPath));
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
          child: Container(
            width: 1.sw,
            decoration: BoxDecoration(
              color: const Color(0xFFcccccc),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.all(16.0.h),
            child: Text(
              widget.prayerText,
              style: TextStyle(fontSize: fontSize.sp, color: Colors.black),
            ),
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
                child: Text(formatDuration(position),
                    style: TextStyle(fontSize: 18.sp, color: Colors.black)),
              ),
            ),
            InkWell(
              onTap: () async {
                if (isPlaying) {
                  await player.pause();
                } else {
                  playSound();
                }
                setState(() {
                  isPlaying = !isPlaying;
                });
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
      // floatingActionButton:
    );
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}
