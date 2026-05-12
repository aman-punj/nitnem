import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/home_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/bani_tiles.dart';
import 'package:nitnem/utils/gradient_scaffold.dart';

class ListingScreen extends StatelessWidget {
  const ListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.isLoading.value && controller.contentItems.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: SacredColors.primaryAccent,
            strokeWidth: 2,
          ),
        );
      }

      final grouped = controller.groupedContent;
      
      final dailyNitnem = grouped['nitnem'] ?? [];
      final otherItems = grouped.entries
          .where((e) => e.key != 'nitnem')
          .expand((e) => e.value)
          .toList();

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Hero Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  Text(
                    'Sacred Library',
                    style: SacredTypography.displayLg.copyWith(
                      color: SacredColors.primaryAccent,
                      fontSize: 40,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore the divine hymns and verses of the Nitnem and Sikh scriptures.',
                    style: SacredTypography.bodyLg.copyWith(
                      color: SacredColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ─── Search Bar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: SacredColors.surfaceContainerLow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SacredColors.borderGold.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SacredColors.primaryAccent.withValues(alpha: 0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(color: SacredColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search for a Bani or Shabad...',
                    hintStyle: TextStyle(
                      color: SacredColors.textSecondary.withValues(alpha: 0.4),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: SacredColors.primaryAccent,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (val) {
                    // TODO: Implement search in HomeController
                  },
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // ─── Daily Nitnem Section (Bento Cards) ────────────────────────
          if (dailyNitnem.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Nitnem',
                      style: SacredTypography.headlineMd.copyWith(
                        color: SacredColors.textPrimary,
                      ),
                    ),
                    Text(
                      'View All',
                      style: SacredTypography.labelSm.copyWith(
                        color: SacredColors.primaryAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = dailyNitnem[index];
                    return SpecialBaniTile(
                      title: item.titles.en,
                      gurmukhiTitle: item.titles.pa,
                      icon: _getBaniIcon(item.id),
                      onTap: () => controller.onContentTap(item),
                    );
                  },
                  childCount: dailyNitnem.length,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ─── Other Banis Section (Compact Tiles) ───────────────────────
          if (otherItems.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  'Other Banis',
                  style: SacredTypography.headlineMd.copyWith(
                    color: SacredColors.textPrimary,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = otherItems[index];
                    return BaniListTile(
                      title: item.titles.getForLanguage(controller.currentLang.value),
                      subtitle: item.titles.pa,
                      icon: _getBaniIcon(item.id),
                      onTap: () => controller.onContentTap(item),
                    );
                  },
                  childCount: otherItems.length,
                ),
              ),
            ),
          ],

          // ─── Decorative Spacer ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Icon(
                    Icons.spa_rounded,
                    color: SacredColors.primaryAccent,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  IconData _getBaniIcon(String id) {
    switch (id.toLowerCase()) {
      case 'japji_sahib':
        return Icons.wb_sunny_outlined;
      case 'jaap_sahib':
        return Icons.auto_awesome_rounded;
      case 'rehras_sahib':
        return Icons.nights_stay_rounded;
      case 'chaupai_sahib':
        return Icons.shield_outlined;
      case 'anand_sahib':
        return Icons.favorite_border_outlined;
      default:
        return Icons.auto_stories_outlined;
    }
  }
}
