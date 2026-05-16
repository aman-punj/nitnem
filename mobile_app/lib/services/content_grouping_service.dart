import '../models/content_category.dart';
import '../models/content_item.dart';

/// Service for grouping and organizing content items by category
class ContentGroupingService {
  /// Groups content items by categoryId and sorts them internally
  ///
  /// Returns a Map where:
  /// - Key: categoryId
  /// - Value: List of ContentItem sorted by displayOrder (ascending)
  ///
  /// Only includes enabled items. Items are sorted by displayOrder within each category.
  static Map<String, List<ContentItem>> groupByCategory(
    List<ContentItem> items, {
    String searchQuery = '',
  }) {
    final grouped = <String, List<ContentItem>>{};

    for (final item in items) {
      if (!item.enabled) continue;

      // Apply search filter if provided
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesSearch = item.titles.en.toLowerCase().contains(query) ||
            item.titles.pa.toLowerCase().contains(query) ||
            item.titles.hi.toLowerCase().contains(query);

        if (!matchesSearch) continue;
      }

      // Group by categoryId
      grouped.putIfAbsent(item.categoryId, () => <ContentItem>[]).add(item);
    }

    // Sort items within each category by displayOrder (ascending)
    grouped.forEach((categoryId, items) {
      items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    });

    return grouped;
  }

  /// Gets sorted category IDs based on category display order
  static List<String> getSortedCategoryIds(
    List<String> categoryIds,
    Map<String, ContentCategory> categoryMap,
  ) {
    final sorted = List<String>.from(categoryIds);
    sorted.sort((a, b) {
      final catA = categoryMap[a];
      final catB = categoryMap[b];
      final orderA = catA?.displayOrder ?? 100;
      final orderB = catB?.displayOrder ?? 100;
      return orderA.compareTo(orderB);
    });
    return sorted;
  }

  /// Gets a friendly display title for a category
  static String getCategoryDisplayTitle(
    String categoryId,
    ContentCategory? category,
  ) {
    if (category != null && category.title.isNotEmpty) {
      return category.title;
    }

    // Fallback friendly names
    switch (categoryId.toLowerCase()) {
      case 'nitnem':
        return 'Nitnem';
      case 'daily':
        return 'Daily Banis';
      case 'evening':
        return 'Evening Banis';
      case 'youtube_live':
      case 'youtube live':
        return 'YouTube Live';
      case 'live':
        return 'Live';
      default:
        return 'Other Banis';
    }
  }
}
