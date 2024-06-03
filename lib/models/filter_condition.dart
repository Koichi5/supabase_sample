class FilterCondition {
  final bool isFilteredByWeek;
  final bool isFilteredByTitle;
  final bool isFilteredByTitleContain;
  final bool isOrderedByCreatedAt;
  final bool isLimited;
  final String? filterTitle;
  final String? filterTitleContain;
  final int? limitCount;

  FilterCondition({
    required this.isFilteredByWeek,
    required this.isFilteredByTitle,
    required this.isFilteredByTitleContain,
    required this.isOrderedByCreatedAt,
    required this.isLimited,
    this.filterTitle,
    this.filterTitleContain,
    this.limitCount,
  });
}
