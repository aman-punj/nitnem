import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/home_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/bani_tiles.dart';
import 'package:nitnem/models/content_category.dart';

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

      final groupedContent = _groupContentByCategories(controller);
      final categoryMap = {
        for (final category in controller.categories) category.id: category
      };
      final orderedCategoryIds = [
        ...controller.categories
            .where((cat) => cat.enabled)
            .map((cat) => cat.id),
        ...groupedContent.keys
            .where((id) => !categoryMap.containsKey(id))
            .toList()
          ..sort(),
      ].toSet().toList();

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Search Bar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      SacredColors.surfaceContainerLow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(25),
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
                    controller.searchQuery.value = val;
                  },
                ),
              ),
            ),
          ),

          // ─── Content Sections ───────────────────────────────────────────
          ..._buildCategorySections(
              orderedCategoryIds, categoryMap, groupedContent, controller),

          // ─── Bottom Spacer ──────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      );
    });
  }

  List<Widget> _buildCategorySections(
    List<String> orderedCategoryIds,
    Map<String, ContentCategory> categoryMap,
    Map<String, List<dynamic>> groupedContent,
    HomeController controller,
  ) {
    final sections = <Widget>[];

    if (controller.contentItems.isEmpty && !controller.isLoading.value) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'No content available yet.',
              style: TextStyle(color: SacredColors.textSecondary),
            ),
          ),
        ),
      ];
    }

    for (final categoryId in orderedCategoryIds) {
      final category = categoryMap[categoryId];
      final items = groupedContent[categoryId] ?? [];
      if (items.isEmpty) continue;

      final title = category?.title ?? _friendlyCategoryTitle(categoryId);
      final iconKey = category?.iconKey;

      sections.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              title,
              style: SacredTypography.headlineMd.copyWith(
                color: SacredColors.textPrimary,
              ),
            ),
          ),
        ),
      );

      sections.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                final isFirstInCategory = index == 0;
                final isPinned = item.pinToTop;

                if (isFirstInCategory && categoryId == 'nitnem' || isPinned) {
                  return SpecialBaniTile(
                    englishTitle: item.titles.en,
                    gurmukhiTitle: item.titles.pa,
                    icon: _getIconForCategory(iconKey),
                    onTap: () => controller.onContentTap(item),
                  );
                } else {
                  return BaniListTile(
                    gurmukhiTitle: item.titles.pa,
                    englishTitle: item.titles.en,
                    icon: _getIconForCategory(iconKey),
                    onTap: () => controller.onContentTap(item),
                  );
                }
              },
              childCount: items.length,
            ),
          ),
        ),
      );

      sections.add(const SliverToBoxAdapter(child: SizedBox(height: 16)));
    }

    return sections;
  }

  Map<String, List<dynamic>> _groupContentByCategories(
      HomeController controller) {
    final grouped = <String, List<dynamic>>{};
    final searchQuery = controller.searchQuery.value.toLowerCase();

    for (final item in controller.contentItems) {
      if (item.enabled) {
        // Apply search filter
        final matchesSearch = searchQuery.isEmpty ||
            item.titles.en.toLowerCase().contains(searchQuery) ||
            item.titles.pa.toLowerCase().contains(searchQuery) ||
            item.titles.hi.toLowerCase().contains(searchQuery);

        if (matchesSearch) {
          grouped.putIfAbsent(item.categoryId, () => []).add(item);
        }
      }
    }

    // Sort items within each category
    grouped.forEach((categoryId, items) {
      items.sort((a, b) {
        // Pinned items first, then by display order
        if (a.pinToTop != b.pinToTop) return a.pinToTop ? -1 : 1;
        return a.displayOrder.compareTo(b.displayOrder);
      });
    });

    return grouped;
  }

  String _friendlyCategoryTitle(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'nitnem':
        return 'Nitnem';
      case 'daily':
        return 'Daily Banis';
      case 'evening':
        return 'Evening Banis';
      case 'live':
        return 'Live';
      default:
        return 'Other Banis';
    }
  }

  IconData _getIconForCategory(String? iconKey) {
    if (iconKey == null) return Icons.auto_stories_outlined;

    switch (iconKey.toLowerCase()) {
      case 'sun':
        return Icons.wb_sunny_outlined;
      case 'star':
        return Icons.auto_awesome_rounded;
      case 'moon':
        return Icons.nights_stay_rounded;
      case 'shield':
        return Icons.shield_outlined;
      case 'heart':
        return Icons.favorite_border_outlined;
      case 'book':
        return Icons.menu_book_rounded;
      case 'live':
        return Icons.live_tv_rounded;
      default:
        return Icons.auto_stories_outlined;
    }
  }
}
