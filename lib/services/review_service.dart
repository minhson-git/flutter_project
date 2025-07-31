
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import 'firebase_service.dart';


class ReviewService {
  static final CollectionReference _reviewsCollection = FirebaseService.reviewsCollection;

  // Helper: convert QuerySnapshot to List<ReviewModel>
  static List<ReviewModel> _toReviewList(QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc))
        .toList();
  }

  // Helper: handle error
  static Exception _handleError(dynamic e) => Exception(FirebaseService.handleFirestoreError(e));

  // Add review
  static Future<String> addReview(ReviewModel review) async {
    try {
      // Check if user already reviewed this movie
      QuerySnapshot existingReview = await _reviewsCollection
          .where('userId', isEqualTo: review.userId)
          .where('movieId', isEqualTo: review.movieId)
          .limit(1)
          .get();

      if (existingReview.docs.isNotEmpty) {
        throw Exception('You have already rated this movie.');
      }

      DocumentReference docRef = await _reviewsCollection.add(review.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Update review
  static Future<void> updateReview(String reviewId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _reviewsCollection.doc(reviewId).update(updates);
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get reviews for a movie
  static Future<List<ReviewModel>> getMovieReviews(String movieId, {int limit = 20}) async {
    try {
      final querySnapshot = await _reviewsCollection
          .where('movieId', isEqualTo: movieId)
          .where('isReported', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return _toReviewList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get user's reviews
  static Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final querySnapshot = await _reviewsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return _toReviewList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get user's review for specific movie
  static Future<ReviewModel?> getUserReviewForMovie(String userId, String movieId) async {
    try {
      QuerySnapshot querySnapshot = await _reviewsCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ReviewModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Like a review
  static Future<void> likeReview(String reviewId, String userId) async {
    try {
      await _reviewsCollection.doc(reviewId).update({
        'likes': FieldValue.arrayUnion([userId]),
        'dislikes': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Dislike a review
  static Future<void> dislikeReview(String reviewId, String userId) async {
    try {
      await _reviewsCollection.doc(reviewId).update({
        'dislikes': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Remove like/dislike
  static Future<void> removeLikeDislike(String reviewId, String userId) async {
    try {
      await _reviewsCollection.doc(reviewId).update({
        'likes': FieldValue.arrayRemove([userId]),
        'dislikes': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Report a review
  static Future<void> reportReview(String reviewId) async {
    try {
      await _reviewsCollection.doc(reviewId).update({
        'isReported': true,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Delete review
  static Future<void> deleteReview(String reviewId) async {
    try {
      await _reviewsCollection.doc(reviewId).delete();
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get movie rating statistics
  static Future<Map<String, dynamic>> getMovieRatingStats(String movieId) async {
    try {
      QuerySnapshot querySnapshot = await _reviewsCollection
          .where('movieId', isEqualTo: movieId)
          .where('isReported', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      List<ReviewModel> reviews = querySnapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      double totalRating = 0;
      Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (ReviewModel review in reviews) {
        totalRating += review.rating;
        int ratingKey = review.rating.round();
        distribution[ratingKey] = (distribution[ratingKey] ?? 0) + 1;
      }

      double averageRating = totalRating / reviews.length;

      return {
        'averageRating': double.parse(averageRating.toStringAsFixed(1)),
        'totalReviews': reviews.length,
        'ratingDistribution': distribution,
      };
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get top reviews (most helpful)
  static Future<List<ReviewModel>> getTopReviews(String movieId, {int limit = 5}) async {
    try {
      final querySnapshot = await _reviewsCollection
          .where('movieId', isEqualTo: movieId)
          .where('isReported', isEqualTo: false)
          .get();
      List<ReviewModel> reviews = _toReviewList(querySnapshot);
      reviews.sort((a, b) => b.helpfulScore.compareTo(a.helpfulScore));
      return reviews.take(limit).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get recent reviews
  static Future<List<ReviewModel>> getRecentReviews({int limit = 10}) async {
    try {
      final querySnapshot = await _reviewsCollection
          .where('isReported', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return _toReviewList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Check if user can review movie (hasn't reviewed before)
  static Future<bool> canUserReviewMovie(String userId, String movieId) async {
    try {
      ReviewModel? existingReview = await getUserReviewForMovie(userId, movieId);
      return existingReview == null;
    } catch (e) {
      return false;
    }
  }
}
