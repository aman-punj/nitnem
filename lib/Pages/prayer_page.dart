import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrayerPage extends StatefulWidget {
  final String prayerText;
  late String prayerName;

  PrayerPage(
      {Key? key,
      required this.prayerText,
      required this.prayerName,
      String? title})
      : super(key: key);

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prayerName),
        backgroundColor: Colors.grey[700],
      ),
      body: SingleChildScrollView(
        child: Stack(
         children: [
           Padding(
             padding:  EdgeInsets.all(16.0.h),
             child: Container(
               decoration: BoxDecoration(
                 color: const Color(0xFFcccccc),
                 border: Border.all(color: Colors.black),
                 borderRadius: BorderRadius.circular(8.0),
               ),
               padding:  EdgeInsets.all(16.0.h),
               child: Text(
                 widget.prayerText,
                 style:  TextStyle(fontSize: 18.sp, color: Colors.black),
               ),
             ),
           ),
           Positioned(child: Padding(padding: EdgeInsets.all(10.h),))
         ],
        ),
      ),
    );
  }
}
