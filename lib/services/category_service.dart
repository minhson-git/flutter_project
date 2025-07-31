import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import 'firebase_service.dart';


class CategoryService {
  static final CollectionReference _categoriesCollection = FirebaseService.categoriesCollection;

  // Helper: convert QuerySnapshot to List<CategoryModel>
  static List<CategoryModel> _toCategoryList(QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  // Helper: handle error
  static Exception _handleError(dynamic e) => Exception(FirebaseService.handleFirestoreError(e));

  // Get all active categories
  static Future<List<CategoryModel>> getAllCategories() async {
    try {
      // Simplify query to avoid index requirement
      final querySnapshot = await _categoriesCollection.get();
      
      // Filter and sort in memory to avoid index requirement
      final allCategories = _toCategoryList(querySnapshot);
      final activeCategories = allCategories
          .where((category) => category.isActive)
          .toList();
      
      // Sort by sortOrder
      activeCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
      return activeCategories;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get category by ID
  static Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      return doc.exists ? CategoryModel.fromFirestore(doc) : null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get category by name
  static Future<CategoryModel?> getCategoryByName(String name) async {
    try {
      QuerySnapshot querySnapshot = await _categoriesCollection
          .where('name', isEqualTo: name)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CategoryModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Create default categories if they don't exist
  static Future<void> createDefaultCategories() async {
    try {
      print('Start creating default categories...');

      List<Map<String, dynamic>> defaultCategories = [
        {
          'name': 'Action',
          'description': 'Action and adventure movies',
          'sortOrder': 1,
        },
        {
          'name': 'Comedy',
          'description': 'Comedy and entertainment movies',
          'sortOrder': 2,
        },
        {
          'name': 'Horror',
          'description': 'Horror and thriller movies',
          'sortOrder': 3,
        },
        {
          'name': 'Romance',
          'description': 'Romance and drama movies',
          'sortOrder': 4,
        },
        {
          'name': 'Sci-Fi',
          'description': 'Science fiction movies',
          'sortOrder': 5,
        },
        {
          'name': 'Documentary',
          'description': 'Documentary and educational movies',
          'sortOrder': 6,
        },
        {
          'name': 'Animation',
          'description': 'Animation and anime movies',
          'sortOrder': 7,
        },
        {
          'name': 'Sports',
          'description': 'Sports and competition movies',
          'sortOrder': 8,
        },
        {
          'name': 'Drama',
          'description': 'Drama and emotional movies',
          'sortOrder': 9,
        },
        {
          'name': 'Thriller',
          'description': 'Thriller and suspense movies',
          'sortOrder': 10,
        },
        {
          'name': 'Fantasy',
          'description': 'Fantasy and magical movies',
          'sortOrder': 11,
        },
        {
          'name': 'Crime',
          'description': 'Crime and mystery movies',
          'sortOrder': 12,
        },
      ];

      for (Map<String, dynamic> categoryData in defaultCategories) {
        try {
          print('Check category: ${categoryData['name']}');
          // Check if category already exists
          CategoryModel? existingCategory = await getCategoryByName(categoryData['name']);

          if (existingCategory == null) {
            print('Create new category: ${categoryData['name']}');
            CategoryModel category = CategoryModel(
              name: categoryData['name'],
              description: categoryData['description'],
              sortOrder: categoryData['sortOrder'],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            await _categoriesCollection.add(category.toFirestore());
            print('Category created: ${categoryData['name']}');
          } else {
            print('Category already exists: ${categoryData['name']}');
          }
        } catch (e) {
          print('Error creating category ${categoryData['name']}: $e');
          throw e;
        }
      }

      print('Complete creating default categories');
    } catch (e) {
      print('Error creating Default Categories: $e');
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Add new category
  static Future<String> addCategory(CategoryModel category) async {
    try {
      DocumentReference docRef = await _categoriesCollection.add(category.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Update category
  static Future<void> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _categoriesCollection.doc(categoryId).update(updates);
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Delete category (soft delete by setting isActive to false)
  static Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Reorder categories
  static Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      WriteBatch batch = FirebaseService.firestore.batch();
      
      for (int i = 0; i < categoryIds.length; i++) {
        DocumentReference docRef = _categoriesCollection.doc(categoryIds[i]);
        batch.update(docRef, {
          'sortOrder': i + 1,
          'updatedAt': Timestamp.now(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Search categories
  static Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      QuerySnapshot querySnapshot = await _categoriesCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }
}
