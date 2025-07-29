import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';


List<UserModel> _toUserList(QuerySnapshot querySnapshot) {
  return querySnapshot.docs
      .map((doc) => UserModel.fromFirestore(doc))
      .toList();
}

Exception _handleError(dynamic e) => Exception(FirebaseService.handleFirestoreError(e));


class UserService {
  static final CollectionReference _usersCollection = FirebaseService.usersCollection;

  // Create new user profile
  static Future<void> createUserProfile(UserModel user) async {
    try {
      print('📝 Creating user profile for: ${user.id}');
      
      // Create map manually to avoid type casting issues
      Map<String, dynamic> userData = {
        'email': user.email,
        'username': user.username,
        'fullName': user.fullName,
        'profileImageUrl': user.profileImageUrl,
        'dateOfBirth': user.dateOfBirth,
        'phoneNumber': user.phoneNumber,
        'favoriteMovies': user.favoriteMovies,
        'watchHistory': user.watchHistory,
        'subscription': user.subscription,
        'createdAt': Timestamp.fromDate(user.createdAt),
        'updatedAt': Timestamp.fromDate(user.updatedAt),
        'isActive': user.isActive,
      };
      
      await _usersCollection.doc(user.id).set(userData);
      print('✅ User profile created successfully');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get user profile by ID
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _usersCollection.doc(userId).update(updates);
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Add movie to favorites
  static Future<void> addToFavorites(String userId, String movieId) async {
    try {
      await _usersCollection.doc(userId).update({
        'favoriteMovies': FieldValue.arrayUnion([movieId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Remove movie from favorites
  static Future<void> removeFromFavorites(String userId, String movieId) async {
    try {
      await _usersCollection.doc(userId).update({
        'favoriteMovies': FieldValue.arrayRemove([movieId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Add movie to watch history
  static Future<void> addToWatchHistory(String userId, String movieId) async {
    try {
      // Remove if already exists to add to the beginning
      await _usersCollection.doc(userId).update({
        'watchHistory': FieldValue.arrayRemove([movieId]),
      });
      
      // Add to the beginning
      await _usersCollection.doc(userId).update({
        'watchHistory': FieldValue.arrayUnion([movieId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Update subscription
  static Future<void> updateSubscription(String userId, String subscription) async {
    try {
      await _usersCollection.doc(userId).update({
        'subscription': subscription,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get user's favorite movies
  static Future<List<String>> getFavoriteMovies(String userId) async {
    try {
      UserModel? user = await getUserProfile(userId);
      return user?.favoriteMovies ?? [];
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Check if movie is in favorites
  static Future<bool> isMovieInFavorites(String userId, String movieId) async {
    try {
      List<String> favorites = await getFavoriteMovies(userId);
      return favorites.contains(movieId);
    } catch (e) {
      return false;
    }
  }

  // Search users by username
  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .where('isActive', isEqualTo: true)
          .limit(20)
          .get();
      return _toUserList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete user profile
  static Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }
}
