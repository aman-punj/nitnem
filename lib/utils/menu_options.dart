import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nitnem/Pages/prayer_page.dart';
import 'package:nitnem/utils/prayer_files/hindi_prayer.dart';
import 'package:nitnem/utils/prayer_files/punjabi_prayer.dart';
import 'package:nitnem/Pages/my_home-page.dart';

import '../routes/routes.dart';

class Menu_option extends StatefulWidget {
  final String text1;
  final String text2;
  final int num;
  final bool isPunjabiSelected;

  const Menu_option(
      {super.key,
      required this.text1,
      required this.num,
      required this.text2,
      required this.isPunjabiSelected});

  @override
  State<Menu_option> createState() => _Menu_optionState();
}

class _Menu_optionState extends State<Menu_option> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
          onTap: () {
            if (widget.isPunjabiSelected == true) {
              // sendRoute(context, RoutesNames.prayerPage);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrayerPage(
                    prayerText: widget.isPunjabiSelected
                        ? punjabiPrayer[widget.num]
                        : hindiPrayer[widget.num],
                    prayerName:
                        widget.isPunjabiSelected ? widget.text1 : widget.text2,
                    num: widget.num,
                  ),
                ),
              );
            } else {
              // sendRoute(context, RoutesNames.prayerPage);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrayerPage(
                          prayerText: hindiPrayer[widget.num],
                          prayerName: widget.isPunjabiSelected
                              ? widget.text1
                              : widget.text2,
                          num: widget.num)));
            }
          },
          child: Container(
            width: 1.sw,
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                widget.isPunjabiSelected ? widget.text1 : widget.text2,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700),
              ),
            ),
          )),
    );
  }
}
