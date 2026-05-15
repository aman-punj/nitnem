import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class ShareService {
  Future<void> shareApp(BuildContext context) async {
    try {
      const imageAssetPath = 'assets/images/bani_sagar_logo.png';
      const fallbackApkUrl =
          'https://drive.google.com/file/d/your_apk_id/view?usp=sharing';

      final byteData = await rootBundle.load(imageAssetPath);
      final buffer = byteData.buffer;

      final tempDir = await getTemporaryDirectory();
      final tempImageFile = File('${tempDir.path}/bani_sagar_logo.png');
      await tempImageFile.writeAsBytes(buffer.asUint8List());

      // Get the rect for iOS/iPad share sheet anchor
      final box = context.findRenderObject() as RenderBox?;
      final rect = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      // In latest share_plus (12.0.0+), SharePlus.instance.share() requires ShareParams.
      // This implementation also handles iPad support via sharePositionOrigin.
      await SharePlus.instance.share(
        ShareParams(
          text: '🌟 Check out the Bani Sagar app!\n\n🔗 $fallbackApkUrl\n\nFeel the divine connection daily 🙏',
          subject: 'Bani Sagar - Daily Nitnem & Bani App',
          files: [XFile(tempImageFile.path)],
          sharePositionOrigin: rect,
        ),
      );
    } catch (e) {
      debugPrint('Sharing failed: $e');
    }
  }
}
