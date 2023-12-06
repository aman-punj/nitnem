import 'package:flutter/material.dart';
import 'package:nitnem/Pages/prayer_page.dart';
import 'package:nitnem/utils/hindi_prayer.dart';
import 'package:nitnem/utils/punjabi_prayer.dart';
import 'package:nitnem/Pages/my_home-page.dart';

class menu_option extends StatelessWidget {
  final String text1;
  final String text2;
  final int num;
  final bool isPunjabiSelected;

  menu_option(
      {super.key, required this.text1, required this.num, required this.text2, required this.isPunjabiSelected });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
          onTap: () {
            if (isPunjabiSelected ==true) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    PrayerPage(prayerText: punjabiPrayer[num])),
              );
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)
              =>
                  PrayerPage(prayerText: hindiPrayer[num]))
            );
            // Handle Hindi selected
          }
          },
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Center(
              child: Text(isPunjabiSelected? text1: text2,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700
                ),
              ),
            ),
          )),

    );
  }
}
