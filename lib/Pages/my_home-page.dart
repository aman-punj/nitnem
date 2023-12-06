import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nitnem/utils/menu_options.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,  String? title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isPunjabiSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: const Text(" Nitnem "),

        /// icon and button for language to shown
        actions: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.0.h),
            child: GestureDetector(
              onTap: () {
                // Toggle between Punjabi and Hindi prayers on button tap
                setState(() {
                  isPunjabiSelected = !isPunjabiSelected;
                  /// idk  how it worked
                  // selectedPrayers =
                  //     isPunjabiSelected ? punjabiPrayer : hindiPrayer;
                });
              },
              child: Row(
                children: [
                  Text(isPunjabiSelected ? 'Punjabi' : 'Hindi'),
                   SizedBox(width: 10.w,),
                   const Icon(Icons.language),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: const  Color(0xFFcccccc),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Column(
              children: [
                Menu_option(
                  text1: "ਜਪੁਜੀ   ਸਾਹਿਬ",
                  text2: "जपजी साहिब",
                  num: 0,
                  isPunjabiSelected: isPunjabiSelected,
                ),
                Menu_option(
                  text1: "ਜਾਪੁ ਸਾਹਿਬ",
                  text2: "जाप साहिब",
                  num: 1,
                  isPunjabiSelected: isPunjabiSelected,
                ),
                Menu_option(
                  text1: "ਤ੍ਵਪ੍ਰਸਾਦਿ ਸਵੈਯੇ",
                  text2: "तव-प्रसाद सवाइये",
                  num: 2,
                  isPunjabiSelected: isPunjabiSelected,
                ),
                Menu_option(
                  text1: "ਚੌਪਈ ਸਾਹਿਬ",
                  text2: "चौपाई साहिब",
                  num: 3,
                  isPunjabiSelected: isPunjabiSelected,
                ),
                Menu_option(
                  text1: "ਅਨੰਦੁ ਸਾਹਿਬ",
                  text2: "आनंद साहिब",
                  num: 4,
                  isPunjabiSelected: isPunjabiSelected,
                ),
                Menu_option(
                  text1: "ਰਹਰਾਸਿ ਸਾਹਿਬ",
                  text2: "रहरास साहिब",
                  num: 5,
                  isPunjabiSelected: isPunjabiSelected,
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
