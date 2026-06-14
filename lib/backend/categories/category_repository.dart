import 'package:restructed/backend/categories/category.dart';

/// Core interface for managing Categories (groups of rules).
/// Categories can be toggled on or off to apply bulk changes to all associated rules.
abstract class CategoryRepository {
  /// Fetches all stored categories from the database.
  Future<List<Category>> getAllCategories();

  /// Looks up a single category by its unique UUID.
  Future<Category?> getCategoryById(String id);

  /// Persists a new category to the database.
  Future<void> createCategory(Category category);

  /// Updates an existing category (e.g. toggling its active state).
  Future<void> updateCategory(Category category);

  /// Permanently deletes a category.
  Future<void> deleteCategory(String id);
}
