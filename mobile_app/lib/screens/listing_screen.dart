import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/home_controller.dart';
import 'package:nitnem/controllers/hukamnama_controller.dart';
import 'package:nitnem/controllers/language_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/bani_tiles.dart';
import 'package:nitnem/models/content_category.dart';
import 'package:nitnem/screens/hukamnama_screen.dart';
import 'package:nitnem/models/content_item.dart';
import 'package:nitnem/models/hukamnama_model.dart';
import 'package:nitnem/controllers/quote_controller.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/services/content_grouping_service.dart';

class ListingScreen extends StatelessWidget {
  const ListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final c = SacredColors.of(context);

    final langController = Get.find<LanguageController>();

    return Obx(() {
      if (controller.isLoading.value && controller.contentItems.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: c.primaryAccent,
            strokeWidth: 2,
          ),
        );
      }

      final currentLang = langController.currentLang.value;
      final searchQuery = controller.searchQuery.value;
      final groupedContent = ContentGroupingService.groupByCategory(
          controller.contentItems,
          searchQuery: searchQuery);
      final categoryMap = {
        for (final category in controller.categories) category.id: category
      };

      final allCategoryIds = groupedContent.keys.toList();
      final sortedCategoryIds = ContentGroupingService.getSortedCategoryIds(
          allCategoryIds, categoryMap);

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Hukamnama Card ───────────────────────────────────────────
            SliverToBoxAdapter(child: _HukamnamaCard()),

            // ─── Search Bar ───────────────────────────────────────────────
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: c.surfaceContainerLow.withValues(alpha: 0.5),
            //         borderRadius: BorderRadius.circular(25),
            //         border: Border.all(
            //           color: c.borderGold.withValues(alpha: 0.1),
            //         ),
            //         boxShadow: [
            //           BoxShadow(
            //             color: c.primaryAccent.withValues(alpha: 0.05),
            //             blurRadius: 20,
            //           ),
            //         ],
            //       ),
            //       child: TextField(
            //         style: TextStyle(color: c.textPrimary),
            //         decoration: InputDecoration(
            //           hintText: 'Search for a Bani or Shabad...',
            //           hintStyle: TextStyle(
            //             color: c.textSecondary.withValues(alpha: 0.4),
            //           ),
            //           prefixIcon: Icon(
            //             Icons.search,
            //             color: c.primaryAccent,
            //             size: 20,
            //           ),
            //           border: InputBorder.none,
            //           contentPadding: const EdgeInsets.symmetric(vertical: 16),
            //         ),
            //         onChanged: (val) {
            //           controller.searchQuery.value = val;
            //         },
            //       ),
            //     ),
            //   ),
            // ),

            // ─── Content Sections ─────────────────────────────────────────
            ..._buildCategorySections(sortedCategoryIds, categoryMap,
                groupedContent, controller, c, currentLang),

            SliverToBoxAdapter(child: _QuoteCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      );
    });
  }

  List<Widget> _buildCategorySections(
    List<String> orderedCategoryIds,
    Map<String, ContentCategory> categoryMap,
    Map<String, List<ContentItem>> groupedContent,
    HomeController controller,
    SacredColors c,
    String currentLang,
  ) {
    final sections = <Widget>[];

    if (controller.contentItems.isEmpty && !controller.isLoading.value) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'No content available yet.',
              style: TextStyle(color: c.textSecondary),
            ),
          ),
        ),
      ];
    }

    for (final categoryId in orderedCategoryIds) {
      final items = groupedContent[categoryId];
      if (items == null || items.isEmpty) continue;

      final category = categoryMap[categoryId];
      final title =
          ContentGroupingService.getCategoryDisplayTitle(categoryId, category);
      final iconKey = category?.iconKey;

      sections.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
            child: Text(
              title,
              style: SacredTypography.headlineMd.copyWith(
                color: c.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );

      sections.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];

                final primaryTitle = item.titles.getForLanguage(currentLang);
                final subtitleTitle =
                    currentLang != 'pa' ? item.titles.pa : item.titles.en;

                if (item.type == ContentType.youtube_live) {
                  return BaniListTile(
                    gurmukhiTitle: primaryTitle,
                    englishTitle: subtitleTitle,
                    iconAsset: 'assets/icons/ic_live.svg',
                    onTap: () => controller.onContentTap(item),
                  );
                }

                final resolvedIconKey = item.iconKey ?? iconKey;
                return BaniListTile(
                  gurmukhiTitle: primaryTitle,
                  englishTitle: subtitleTitle,
                  iconAsset: _getSvgAsset(resolvedIconKey),
                  iconUrl: item.iconUrl,
                  onTap: () => controller.onContentTap(item),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      );

      sections.add(const SliverToBoxAdapter(child: SizedBox(height: 4)));
    }

    return sections;
  }

  String _getSvgAsset(String? iconKey) {
    switch (iconKey?.toLowerCase()) {
      // Per-prayer icons
      case 'japji':       return 'assets/icons/ic_japji.svg';
      case 'jaap':        return 'assets/icons/ic_jaap.svg';
      case 'tav-prasad':  return 'assets/icons/ic_tav_prasad.svg';
      case 'chaupai':     return 'assets/icons/ic_chaupai.svg';
      case 'anand':       return 'assets/icons/ic_anand.svg';
      case 'rehras':      return 'assets/icons/ic_rehras.svg';
      case 'sohila':      return 'assets/icons/ic_sohila.svg';
      // Category icons
      case 'morning':     return 'assets/icons/ic_morning.svg';
      case 'evening':     return 'assets/icons/ic_evening.svg';
      case 'daily':       return 'assets/icons/ic_daily.svg';
      case 'nitnem':      return 'assets/icons/ic_nitnem_cat.svg';
      case 'live':        return 'assets/icons/ic_live.svg';
      // Legacy category icons (backward compat)
      case 'sun':         return 'assets/icons/ic_sun.svg';
      case 'moon':        return 'assets/icons/ic_moon.svg';
      case 'star':        return 'assets/icons/ic_star.svg';
      case 'shield':      return 'assets/icons/ic_shield.svg';
      case 'heart':       return 'assets/icons/ic_heart.svg';
      case 'book':        return 'assets/icons/ic_book.svg';
      default:            return 'assets/icons/ic_bani.svg';
    }
  }
}

// ── Quote card ────────────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return Obx(() {
      final q = Get.find<QuoteController>().homeQuote;
      if (q.text.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SacredSpacing.xl,
          vertical: SacredSpacing.md,
        ),
        child: Container(
          padding: const EdgeInsets.all(SacredSpacing.gutter),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SacredRadius.md),
            border: Border.all(color: c.primaryAccent.withValues(alpha: 0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                c.primaryAccent.withValues(alpha: 0.06),
                c.surfaceContainerLow.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                '"${q.text}"',
                textAlign: TextAlign.center,
                style: SacredTypography.bodyMd.copyWith(
                  color: c.primary,
                  fontStyle: FontStyle.italic,
                  height: 1.55,
                  shadows: [
                    Shadow(
                      color: c.primaryAccent.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              if (q.author != null) ...[
                const SizedBox(height: SacredSpacing.sm),
                Text(
                  '— ${q.author}',
                  textAlign: TextAlign.center,
                  style: SacredTypography.meta.copyWith(
                    color: c.textSecondary.withValues(alpha: 0.7),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

// ── Hukamnama card ────────────────────────────────────────────────────────────

class _HukamnamaCard extends StatelessWidget {
  const _HukamnamaCard();

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    final ctrl = Get.find<HukamnamaController>();

    return Obx(() {
      if (!ctrl.isEnabled.value) return const SizedBox.shrink();
      final data = ctrl.hukamnama.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: GestureDetector(
          onTap: data != null
              ? () => Get.to(() => HukamnamaScreen(data: data))
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.borderGold.withValues(alpha: 0.25)),
            ),
            child: data == null ? _buildLoading(c) : _buildContent(c, data),
          ),
        ),
      );
    });
  }

  Widget _buildLoading(SacredColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hukamnama Sahib',
              style: SacredTypography.bodySm.copyWith(
                color: c.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: c.primaryAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 13,
          width: double.infinity,
          decoration: BoxDecoration(
            color: c.outlineVariant.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 13,
          width: 180,
          decoration: BoxDecoration(
            color: c.outlineVariant.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(SacredColors c, HukamnamaModel data) {
    final lines =
        data.gurmukhi.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final preview = lines.take(2).join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Hukamnama Sahib',
              style: SacredTypography.bodySm.copyWith(
                color: c.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              data.date,
              style: SacredTypography.bodySm.copyWith(color: c.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          preview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Read full',
              style: SacredTypography.bodySm.copyWith(color: c.primaryAccent),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 14, color: c.primaryAccent),
          ],
        ),
      ],
    );
  }
}
