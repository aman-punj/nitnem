import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/hukamnama_model.dart';
import '../../../screens/hukamnama_screen.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class HukamnamaSheet extends StatelessWidget {
  const HukamnamaSheet({super.key, required this.data});

  final HukamnamaModel data;

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'ਹੁਕਮਨਾਮਾ ਸਾਹਿਬ',
                          style: SacredTypography.headlineMd
                              .copyWith(color: c.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          data.date,
                          style: SacredTypography.bodySm
                              .copyWith(color: c.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  if (data.source.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      data.source,
                      style: SacredTypography.bodySm
                          .copyWith(color: c.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Gurmukhi text preview (first 3 lines)
                  Text(
                    _previewGurmukhi(data.gurmukhi),
                    style: TextStyle(
                      fontSize: 18,
                      height: 2.0,
                      color: c.textPrimary,
                    ),
                  ),

                  if (data.translationEnglish.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Divider(color: c.outlineVariant, height: 1),
                    const SizedBox(height: 12),
                    Text(
                      _previewEnglish(data.translationEnglish),
                      style: SacredTypography.bodySm
                          .copyWith(color: c.textSecondary, height: 1.7),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // View Full button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.to(() => HukamnamaScreen(data: data));
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('ਪੂਰਾ ਹੁਕਮਨਾਮਾ ਪੜ੍ਹੋ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.primary,
                        side: BorderSide(color: c.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: bottom > 0 ? 0 : 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _previewGurmukhi(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length <= 4) return text;
    return '${lines.take(4).join('\n')}…';
  }

  String _previewEnglish(String text) {
    const maxChars = 220;
    if (text.length <= maxChars) return text;
    final trimmed = text.substring(0, maxChars).trimRight();
    final lastSpace = trimmed.lastIndexOf(' ');
    return '${trimmed.substring(0, lastSpace)}…';
  }
}
