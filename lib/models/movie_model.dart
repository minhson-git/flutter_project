import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  final String? id;
  final String title;
  final String description;
  final String? posterUrl;
  final String? backdropUrl;
  final String? trailerUrl;
  final int releaseYear;
  final int duration; // in minutes
  final double rating;
  final List<String> genres;
  final List<String> cast;
  final String director;
  final String country;
  final String language;
  final String ageRating; // G, PG, PG-13, R, etc.
  final String quality; // HD, 4K, etc.
  final bool isFeatured;
  final bool isPopular;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MovieModel({
    this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    this.backdropUrl,
    this.trailerUrl,
    required this.releaseYear,
    required this.duration,
    this.rating = 0.0,
    this.genres = const [],
    this.cast = const [],
    required this.director,
    required this.country,
    required this.language,
    this.ageRating = 'PG-13',
    this.quality = 'HD',
    this.isFeatured = false,
    this.isPopular = false,
    this.viewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore document
  factory MovieModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MovieModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      posterUrl: data['posterUrl'],
      backdropUrl: data['backdropUrl'],
      trailerUrl: data['trailerUrl'],
      releaseYear: data['releaseYear'] ?? 0,
      duration: data['duration'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      genres: _parseStringList(data['genres']),
      cast: _parseStringList(data['cast']),
      director: data['director'] ?? '',
      country: data['country'] ?? '',
      language: data['language'] ?? '',
      ageRating: data['ageRating'] ?? 'PG-13',
      quality: data['quality'] ?? 'HD',
      isFeatured: data['isFeatured'] ?? false,
      isPopular: data['isPopular'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'trailerUrl': trailerUrl,
      'releaseYear': releaseYear,
      'duration': duration,
      'rating': rating,
      'genres': genres,
      'cast': cast,
      'director': director,
      'country': country,
      'language': language,
      'ageRating': ageRating,
      'quality': quality,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method for updates
  MovieModel copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    String? backdropUrl,
    String? trailerUrl,
    int? releaseYear,
    int? duration,
    double? rating,
    List<String>? genres,
    List<String>? cast,
    String? director,
    String? country,
    String? language,
    String? ageRating,
    String? quality,
    bool? isFeatured,
    bool? isPopular,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      releaseYear: releaseYear ?? this.releaseYear,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      genres: genres ?? this.genres,
      cast: cast ?? this.cast,
      director: director ?? this.director,
      country: country ?? this.country,
      language: language ?? this.language,
      ageRating: ageRating ?? this.ageRating,
      quality: quality ?? this.quality,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  //Helper method to safely parse string lists
  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }
}
