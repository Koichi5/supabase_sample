class FilterCondition {
  final bool isFilteredByWeek;
  final bool isFilteredByTitle;
  final bool isOrderedByCreatedAt;
  final bool isLimited;
  final String? filterTitle;
  final int? limitCount;

  FilterCondition({
    required this.isFilteredByWeek,
    required this.isFilteredByTitle,
    required this.isOrderedByCreatedAt,
    required this.isLimited,
    this.filterTitle,
    this.limitCount,
  });
}
