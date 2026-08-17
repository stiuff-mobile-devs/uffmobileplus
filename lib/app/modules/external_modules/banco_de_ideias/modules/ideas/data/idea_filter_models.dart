class IdeaActiveFilter {
  const IdeaActiveFilter({
    required this.type,
    required this.label,
    required this.value,
  });

  final IdeaActiveFilterType type;
  final String label;
  final String value;
}

enum IdeaActiveFilterType { titulo, tipo, categoria }
