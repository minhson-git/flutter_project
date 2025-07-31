import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String? id;
  final String userId;
  final String name;
  final String description;
  final String? thumbnailUrl;
  final List<String> movieIds;
  final bool isPublic;
  final bool isDefault; // For system-generated playlists like "Watch Later", "Favorites"
  final List<String> sharedWith; // User IDs who can access this playlist
  final int totalDuration; // in minutes
  final DateTime createdAt;
  final DateTime updatedAt;

  PlaylistModel({
    this.id,
    required this.userId,
    required this.name,
    this.description = '',
    this.thumbnailUrl,
    this.movieIds = const [],
    this.isPublic = false,
    this.isDefault = false,
    this.sharedWith = const [],
    this.totalDuration = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get movie count
  int get movieCount => movieIds.length;

  // Convert from Firestore document
  factory PlaylistModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlaylistModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      movieIds: _parseStringList(data['movieIds']),
      isPublic: data['isPublic'] ?? false,
      isDefault: data['isDefault'] ?? false,
      sharedWith: _parseStringList(data['sharedWith']),
      totalDuration: data['totalDuration'] ?? 0,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'movieIds': movieIds,
      'isPublic': isPublic,
      'isDefault': isDefault,
      'sharedWith': sharedWith,
      'totalDuration': totalDuration,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method for updates
  PlaylistModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? thumbnailUrl,
    List<String>? movieIds,
    bool? isPublic,
    bool? isDefault,
    List<String>? sharedWith,
    int? totalDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      movieIds: movieIds ?? this.movieIds,
      isPublic: isPublic ?? this.isPublic,
      isDefault: isDefault ?? this.isDefault,
      sharedWith: sharedWith ?? this.sharedWith,
      totalDuration: totalDuration ?? this.totalDuration,
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
