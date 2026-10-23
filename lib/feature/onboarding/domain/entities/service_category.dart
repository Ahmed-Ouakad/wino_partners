/// Domain entity representing a business / service category.
class ServiceCategory {
  final String id;
  final String title;
  final List<String> subCategories;

  const ServiceCategory({
    required this.id,
    required this.title,
    this.subCategories = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() => 'ServiceCategory(id: $id, title: $title)';
}
