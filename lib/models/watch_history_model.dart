import 'package:cloud_firestore/cloud_firestore.dart';

class WatchHistoryModel {
  final String? id;
  final String userId;
  final String movieId;
  final int watchDuration; // in seconds
  final int totalDuration; // in seconds
  final bool isCompleted;
  final DateTime watchedAt;
  final DateTime lastWatchedAt;

  WatchHistoryModel({
    this.id,
    required this.userId,
    required this.movieId,
    this.watchDuration = 0,
    required this.totalDuration,
    this.isCompleted = false,
    required this.watchedAt,
    required this.lastWatchedAt,
  });

  // Calculate watch progress percentages
  double get progressPercentage {
    if (totalDuration == 0) return 0.0;
    return (watchDuration / totalDuration) * 100;
  }

  // Check if movie is almost finished (watched more than 90%)
  bool get isAlmostFinished => progressPercentage >= 90;

  // Convert from Firestore document
  factory WatchHistoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WatchHistoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      watchDuration: data['watchDuration'] ?? 0,
      totalDuration: data['totalDuration'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      watchedAt: data['watchedAt']?.toDate() ?? DateTime.now(),
      lastWatchedAt: data['lastWatchedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'movieId': movieId,
      'watchDuration': watchDuration,
      'totalDuration': totalDuration,
      'isCompleted': isCompleted,
      'watchedAt': Timestamp.fromDate(watchedAt),
      'lastWatchedAt': Timestamp.fromDate(lastWatchedAt),
    };
  }

  // Copy with method for updates
  WatchHistoryModel copyWith({
    String? id,
    String? userId,
    String? movieId,
    int? watchDuration,
    int? totalDuration,
    bool? isCompleted,
    DateTime? watchedAt,
    DateTime? lastWatchedAt,
  }) {

    return WatchHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      watchDuration: watchDuration ?? this.watchDuration,
      totalDuration: totalDuration ?? this.totalDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      watchedAt: watchedAt ?? this.watchedAt,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
    );
  }
}
