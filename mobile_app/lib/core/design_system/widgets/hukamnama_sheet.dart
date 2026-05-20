import 'package:flutter/material.dart';

import '../../../models/hukamnama_model.dart';
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
              padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Hukamnama Sahib',
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

                  // Gurmukhi text — system font so Gurmukhi script renders correctly
                  Text(
                    data.gurmukhi,
                    style: TextStyle(
                      fontSize: 18,
                      height: 2.0,
                      color: c.textPrimary,
                    ),
                  ),

                  // English translation
                  if (data.translationEnglish.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Divider(color: c.outlineVariant, height: 1),
                    const SizedBox(height: 20),
                    Text(
                      data.translationEnglish,
                      style: SacredTypography.bodySm
                          .copyWith(color: c.textSecondary, height: 1.7),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
