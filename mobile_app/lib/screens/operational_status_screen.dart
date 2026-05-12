import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/sacred_button.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';

enum OperationalStatus { maintenance, forceUpdate }

class OperationalStatusScreen extends StatelessWidget {
  final OperationalStatus status;
  final String message;
  final String? storeUrl;

  const OperationalStatusScreen({
    super.key,
    required this.status,
    required this.message,
    this.storeUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMaintenance = status == OperationalStatus.maintenance;

    return GradientScaffold(
      showKhandaSymbol: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with glow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isMaintenance
                          ? Colors.orangeAccent
                          : SacredColors.primaryAccent)
                      .withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: (isMaintenance
                              ? Colors.orangeAccent
                              : SacredColors.primaryAccent)
                          .withValues(alpha: 0.05),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  isMaintenance ? Icons.engineering_rounded : Icons.system_update_rounded,
                  size: 50,
                  color: isMaintenance ? Colors.orangeAccent : SacredColors.primaryAccent,
                ),
              ),
              const SizedBox(height: 48),
              
              // Title
              Text(
                isMaintenance ? 'Sanctuary Under Care' : 'New Presence Awaits',
                textAlign: TextAlign.center,
                style: SacredTypography.displayLg.copyWith(
                  fontSize: 32,
                  color: SacredColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: SacredTypography.bodyLg.copyWith(
                  color: SacredColors.textSecondary.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              
              // Action Button
              if (!isMaintenance && storeUrl != null)
                SacredButton(
                  label: 'Update Now',
                  onPressed: () async {
                    final Uri url = Uri.parse(storeUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
              
              if (isMaintenance)
                 Text(
                    'WE WILL RETURN SHORTLY',
                    style: SacredTypography.labelSm.copyWith(
                      color: SacredColors.primaryAccent.withValues(alpha: 0.5),
                      letterSpacing: 4.0,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
