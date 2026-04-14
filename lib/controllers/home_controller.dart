import 'package:get/get.dart';

import '../screens/prayer_page.dart';
import '../services/transcript_path_service.dart';

class HomeController extends GetxController {
  final TranscriptPathService transcriptPathService;

  HomeController({required this.transcriptPathService});

  final currentLang = 'pn';

  final baniList = [
    {
      'id': 'japji_sahib',
      'pn': 'ਜਪੁਜੀ ਸਾਹਿਬ',
      'hi': 'जपुजी साहिब',
      'en': 'Japji Sahib'
    },
    {
      'id': 'jaap_sahib',
      'pn': 'ਜਾਪ ਸਾਹਿਬ',
      'hi': 'जाप साहिब',
      'en': 'Jaap Sahib'
    },
    {
      'id': 'tav_prasad',
      'pn': 'ਤਵ ਪ੍ਰਸਾਦ ਸਵੱਯੇ',
      'hi': 'तव प्रसाद सवये',
      'en': 'Tav Prasad Savaiye'
    },
    {
      'id': 'chaupai_sahib',
      'pn': 'ਚੌਪਈ ਸਾਹਿਬ',
      'hi': 'चौपई साहिब',
      'en': 'Chaupai Sahib'
    },
    {
      'id': 'anand_sahib',
      'pn': 'ਆਨੰਦ ਸਾਹਿਬ',
      'hi': 'आनंद साहिब',
      'en': 'Anand Sahib'
    },
    {
      'id': 'rehras_sahib',
      'pn': 'ਰਹਿਰਾਸ ਸਾਹਿਬ',
      'hi': 'रेहरास साहिब',
      'en': 'Rehras Sahib'
    },
    {
      'id': 'kirtan_sohila',
      'pn': 'ਕੀਰਤਨ ਸੋਹਿਲਾ',
      'hi': 'कीरतन सोहिला',
      'en': 'Kirtan Sohila'
    },
  ];

  void openPrayer(String prayerId, String title) async {
    final transcriptPath = await transcriptPathService.getTranscriptPath(
      prayerId: prayerId,
      languageCode: currentLang,
    );

    print("this is the path - $transcriptPath");

    Get.to(() => PrayerPage(
          title: title,
          audioAssetPath: 'assets/audios/$prayerId.mp3',
          transcriptAssetPath: transcriptPath,
        ));
  }
}
