import 'package:drift/drift.dart';
import 'package:restructed/backend/categories/category.dart' as entity;
import 'package:restructed/backend/categories/category_repository.dart';
import 'package:restructed/backend/core/database.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;

  CategoryRepositoryImpl(this.db);

  entity.Category mapToEntity(Category driftCategory) {
    return entity.Category(
      id: driftCategory.id,
      name: driftCategory.name,
      isDefault: driftCategory.isDefault,
      icon: driftCategory.icon,
      description: driftCategory.description,
      isActive: driftCategory.isActive,
      syncStatus: driftCategory.syncStatus,
    );
  }

  CategoriesCompanion mapToCompanion(entity.Category category) {
    return CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      isDefault: Value(category.isDefault),
      icon: Value(category.icon),
      description: Value(category.description),
      isActive: Value(category.isActive),
      syncStatus: Value(category.syncStatus),
    );
  }

  @override
  Future<void> createCategory(entity.Category category) async {
    await db.into(db.categories).insert(mapToCompanion(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }

  @override
  Future<List<entity.Category>> getAllCategories() async {
    final categories = await db.select(db.categories).get();
    return categories.map(mapToEntity).toList();
  }

  @override
  Future<entity.Category?> getCategoryById(String id) async {
    final category = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (category == null) return null;
    return mapToEntity(category);
  }

  @override
  Future<void> updateCategory(entity.Category category) async {
    await db.update(db.categories).replace(mapToCompanion(category));
  }
}
