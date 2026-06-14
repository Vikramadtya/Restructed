/// Represents a category of blocked websites.
class Category {
  final String id;
  final String name;
  final bool isDefault;
  final String? icon;
  final String? description;
  final bool isActive;
  final String syncStatus;

  const Category({
    required this.id,
    required this.name,
    this.isDefault = false,
    this.icon,
    this.description,
    this.isActive = true,
    this.syncStatus = 'synced',
  });

  Category copyWith({
    String? id,
    String? name,
    bool? isDefault,
    String? icon,
    String? description,
    bool? isActive,
    String? syncStatus,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault,
      'icon': icon,
      'description': description,
      'isActive': isActive,
      'syncStatus': syncStatus,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      isDefault: (json['isDefault'] as bool?) ?? false,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      syncStatus: (json['syncStatus'] as String?) ?? 'synced',
    );
  }
}
