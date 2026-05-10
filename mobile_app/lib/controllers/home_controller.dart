import 'package:get/get.dart';
import 'package:nitnem/services/prayer_asset_service.dart';

import '../screens/prayer_page.dart';
import '../services/transcript_path_service.dart';

class HomeController extends GetxController {
  final TranscriptPathService transcriptPathService;
  final PrayerAssetService prayerAssetService;

  HomeController({
    required this.transcriptPathService,
    required this.prayerAssetService,
  });

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
    final localTranscript = await prayerAssetService.existingTranscript(
      prayerId: prayerId,
      languageCode: currentLang,
    );
    final localAudio = await prayerAssetService.existingAudio(prayerId: prayerId);

    final transcriptPath = localTranscript?.path ??
        await transcriptPathService.getTranscriptPath(
      prayerId: prayerId,
      languageCode: currentLang,
    );

    Get.to(() => PrayerPage(
          title: title,
          audioPath: localAudio?.path ?? 'assets/audios/$prayerId.mp3',
          transcriptPath: transcriptPath,
          audioIsLocalFile: localAudio != null,
          transcriptIsLocalFile: localTranscript != null,
        ));
  }
}
