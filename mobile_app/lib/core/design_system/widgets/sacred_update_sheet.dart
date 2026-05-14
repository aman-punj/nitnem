import 'package:flutter/material.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class SacredUpdateSheet extends StatelessWidget {
  final String title;
  final String body;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final String storeUrl;
  final VoidCallback? onSecondaryPressed;

  const SacredUpdateSheet({
    super.key,
    required this.title,
    required this.body,
    required this.primaryButtonText,
    this.secondaryButtonText,
    required this.storeUrl,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SacredAppSheet(
      title: title,
      body: body,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onSecondaryPressed: onSecondaryPressed,
      type: SacredAppSheetType.update,
      onPrimaryPressed: () async {
        if (storeUrl.trim().isEmpty) return;
        final uri = Uri.parse(storeUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
