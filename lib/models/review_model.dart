import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String? id;
  final String userId;
  final String movieId;
  final double rating; // 1-5 stars
  final String comment;
  final bool isRecommended;
  final List<String> likes; // User IDs who liked this review
  final List<String> dislikes; // User IDs who disliked this review
  final bool isReported;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    this.id,
    required this.userId,
    required this.movieId,
    required this.rating,
    required this.comment,
    this.isRecommended = true,
    this.likes = const [],
    this.dislikes = const [],
    this.isReported = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate helpful score (likes - dislikes)
  int get helpfulScore => likes.length - dislikes.length;

  // Convert from Firestore document
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      isRecommended: data['isRecommended'] ?? true,
      likes: _parseStringList(data['likes']),
      dislikes: _parseStringList(data['dislikes']),
      isReported: data['isReported'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'movieId': movieId,
      'rating': rating,
      'comment': comment,
      'isRecommended': isRecommended,
      'likes': likes,
      'dislikes': dislikes,
      'isReported': isReported,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method for updates
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? movieId,
    double? rating,
    String? comment,
    bool? isRecommended,
    List<String>? likes,
    List<String>? dislikes,
    bool? isReported,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isRecommended: isRecommended ?? this.isRecommended,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      isReported: isReported ?? this.isReported,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to safely parse string lists
  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }
}
