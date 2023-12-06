import 'package:flutter/material.dart';
import 'package:nitnem/utils/menu_options.dart';
import 'package:nitnem/utils/punjabi_prayer.dart';
import 'package:nitnem/utils/hindi_prayer.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isPunjabiSelected = true;

  // List<String> selectedPrayers = punjabiPrayer;

  // Track selected language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: Text(" Nitnem "),

        /// icon and button for language to shown
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Text(isPunjabiSelected ? 'Punjabi' : 'Hindi'),
                IconButton(
                  icon: const Icon(Icons.language),
                  tooltip: 'Language',
                  onPressed: () {
                    // Toggle between Punjabi and Hindi prayers on button tap
                    setState(() {
                      isPunjabiSelected = !isPunjabiSelected;

                      /// idk  how it worked
                      // selectedPrayers =
                      //     isPunjabiSelected ? punjabiPrayer : hindiPrayer;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFcccccc),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Column(
                children: [
                  menu_option(
                    text1: "ਜਪੁਜੀ ਸਾਹਿਬ",
                    text2: "जपजी साहिब",
                    num: 0,
                    isPunjabiSelected: isPunjabiSelected,
                  ),
                  menu_option(
                    text1: "ਜਾਪੁ ਸਾਹਿਬ",
                    text2: "जाप साहिब",
                    num: 1,
                    isPunjabiSelected: isPunjabiSelected,
                  ),
                  menu_option(
                    text1: "ਤ੍ਵਪ੍ਰਸਾਦਿ ਸਵੈਯੇ",
                    text2: "तव-प्रसाद सवाइये",
                    num: 2,
                    isPunjabiSelected: isPunjabiSelected,
                  ),
                  menu_option(
                    text1: "ਚੌਪਈ ਸਾਹਿਬ",
                    text2: "चौपाई साहिब",
                    num: 3,
                    isPunjabiSelected: isPunjabiSelected,
                  ),
                  menu_option(
                    text1: "ਅਨੰਦੁ ਸਾਹਿਬ",
                    text2: "आनंद साहिब",
                    num: 4,
                    isPunjabiSelected: isPunjabiSelected,
                  ),
                  menu_option(
                    text1: "ਰਹਰਾਸਿ ਸਾਹਿਬ",
                    text2: "रहरास साहिब",
                    num: 5,
                    isPunjabiSelected: isPunjabiSelected,
                  ),
                  // ElevatedButton.icon(
                  //   onPressed: ()
                  //   icon: Icon(Icons.search),
                  //   label:
                  // ),
                ],
              ),
              Spacer()
            ],
          ),
        ),
      ),
    );
  }
}
