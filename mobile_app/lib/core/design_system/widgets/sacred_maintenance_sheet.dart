import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nitnem/core/design_system/widgets/sacred_app_sheet.dart';

class SacredMaintenanceSheet extends StatelessWidget {
  final String title;
  final String body;
  final String primaryButtonText;

  const SacredMaintenanceSheet({
    super.key,
    required this.title,
    required this.body,
    required this.primaryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return SacredAppSheet(
      title: title,
      body: body,
      primaryButtonText: primaryButtonText,
      type: SacredAppSheetType.maintenance,
      onPrimaryPressed: () => exit(0),
    );
  }
}
