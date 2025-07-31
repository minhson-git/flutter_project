
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/watch_history_model.dart';
import 'firebase_service.dart';


class WatchHistoryService {
  static final CollectionReference _watchHistoryCollection = FirebaseService.watchHistoryCollection;

  // Helper: convert QuerySnapshot to List<WatchHistoryModel>
  static List<WatchHistoryModel> _toWatchHistoryList(QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((doc) => WatchHistoryModel.fromFirestore(doc))
        .toList();
  }

  // Helper: handle error
  static Exception _handleError(dynamic e) => Exception(FirebaseService.handleFirestoreError(e));

  // Add or update watch history
  static Future<void> addOrUpdateWatchHistory(WatchHistoryModel watchHistory) async {
    try {
      // Check if watch history already exists for this user and movie
      QuerySnapshot existingQuery = await _watchHistoryCollection
          .where('userId', isEqualTo: watchHistory.userId)
          .where('movieId', isEqualTo: watchHistory.movieId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        // Update existing record
        String docId = existingQuery.docs.first.id;
        WatchHistoryModel existing = WatchHistoryModel.fromFirestore(existingQuery.docs.first);
        
        WatchHistoryModel updated = existing.copyWith(
          watchDuration: watchHistory.watchDuration,
          isCompleted: watchHistory.isCompleted,
          lastWatchedAt: DateTime.now(),
        );
        
        await _watchHistoryCollection.doc(docId).update(updated.toFirestore());
      } else {
        // Create new record
        await _watchHistoryCollection.add(watchHistory.toFirestore());
      }
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get user's watch history
  static Future<List<WatchHistoryModel>> getUserWatchHistory(String userId, {int limit = 20}) async {
    try {
      final querySnapshot = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .orderBy('lastWatchedAt', descending: true)
          .limit(limit)
          .get();
      return _toWatchHistoryList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get user's continue watching (incomplete movies)
  static Future<List<WatchHistoryModel>> getContinueWatching(String userId) async {
    try {
      final querySnapshot = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .where('watchDuration', isGreaterThan: 0)
          .orderBy('watchDuration')
          .orderBy('lastWatchedAt', descending: true)
          .limit(10)
          .get();
      return _toWatchHistoryList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get watch history for specific movie and user
  static Future<WatchHistoryModel?> getWatchHistoryForMovie(String userId, String movieId) async {
    try {
      QuerySnapshot querySnapshot = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return WatchHistoryModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Update watch progress
  static Future<void> updateWatchProgress(
    String userId, 
    String movieId, 
    int watchDuration, 
    int totalDuration
  ) async {
    try {
      bool isCompleted = watchDuration >= (totalDuration * 0.9); // 90% completion

      WatchHistoryModel watchHistory = WatchHistoryModel(
        userId: userId,
        movieId: movieId,
        watchDuration: watchDuration,
        totalDuration: totalDuration,
        isCompleted: isCompleted,
        watchedAt: DateTime.now(),
        lastWatchedAt: DateTime.now(),
      );

      await addOrUpdateWatchHistory(watchHistory);
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Mark movie as completed
  static Future<void> markAsCompleted(String userId, String movieId) async {
    try {
      QuerySnapshot querySnapshot = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        await _watchHistoryCollection.doc(docId).update({
          'isCompleted': true,
          'lastWatchedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get completed movies for user
  static Future<List<WatchHistoryModel>> getCompletedMovies(String userId) async {
    try {
      final querySnapshot = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .orderBy('lastWatchedAt', descending: true)
          .get();
      return _toWatchHistoryList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete watch history record
  static Future<void> deleteWatchHistory(String userId, String movieId) async {
    try {
      QuerySnapshot querySnapshot = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _watchHistoryCollection.doc(querySnapshot.docs.first.id).delete();
      }
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Clear all watch history for user
  static Future<void> clearUserWatchHistory(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .get();

      WriteBatch batch = FirebaseService.firestore.batch();
      
      for (DocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get watch statistics for user
  static Future<Map<String, dynamic>> getUserWatchStats(String userId) async {
    try {
      QuerySnapshot allHistory = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .get();

      QuerySnapshot completedHistory = await _watchHistoryCollection
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .get();

      int totalWatched = allHistory.docs.length;
      int completed = completedHistory.docs.length;
      
      // Calculate total watch time
      int totalWatchTime = 0;
      for (DocumentSnapshot doc in allHistory.docs) {
        WatchHistoryModel history = WatchHistoryModel.fromFirestore(doc);
        totalWatchTime += history.watchDuration;
      }

      return {
        'totalMoviesWatched': totalWatched,
        'completedMovies': completed,
        'totalWatchTimeSeconds': totalWatchTime,
        'totalWatchTimeHours': (totalWatchTime / 3600).round(),
      };
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }
}
