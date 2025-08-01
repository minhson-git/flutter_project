
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';
import 'firebase_service.dart';

class MovieService {
  static final CollectionReference _moviesCollection = FirebaseService.moviesCollection;

  // Helper: convert QuerySnapshot to List<MovieModel>
  static List<MovieModel> _toMovieList(QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((doc) => MovieModel.fromFirestore(doc))
        .toList();
  }

  // Helper: handle error
  static Exception _handleError(dynamic e) => Exception(FirebaseService.handleFirestoreError(e));

  // Get all movies
  static Future<List<MovieModel>> getAllMovies() async {
    try {
      final querySnapshot = await _moviesCollection.orderBy('createdAt', descending: true).get();
      return _toMovieList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get movie by ID
  static Future<MovieModel?> getMovieById(String movieId) async {
    try {
      final doc = await _moviesCollection.doc(movieId).get();
      return doc.exists ? MovieModel.fromFirestore(doc) : null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get movies by IDs
  static Future<List<MovieModel>> getMoviesByIds(List<String> movieIds) async {
    try {
      if (movieIds.isEmpty) return [];
      List<MovieModel> allMovies = [];
      for (int i = 0; i < movieIds.length; i += 10) {
        final batch = movieIds.skip(i).take(10).toList();
        final querySnapshot = await _moviesCollection.where(FieldPath.documentId, whereIn: batch).get();
        allMovies.addAll(_toMovieList(querySnapshot));
      }
      return allMovies;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get featured movies
  static Future<List<MovieModel>> getFeaturedMovies() async {
    try {
      // Simplify query to avoid index requirement
      final querySnapshot = await _moviesCollection.get();
      final allMovies = _toMovieList(querySnapshot);
      
      // Filter and sort in memory
      final featuredMovies = allMovies
          .where((movie) => movie.isFeatured)
          .toList();
      
      // Sort by createdAt descending  
      featuredMovies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Limit to 10
      return featuredMovies.take(10).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get popular movies
  static Future<List<MovieModel>> getPopularMovies() async {
    try {
      // Simplify query to avoid index requirement
      final querySnapshot = await _moviesCollection.get();
      final allMovies = _toMovieList(querySnapshot);
      
      // Filter and sort in memory
      final popularMovies = allMovies
          .where((movie) => movie.isPopular)
          .toList();
      
      // Sort by viewCount descending
      popularMovies.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      
      // Limit to 20
      return popularMovies.take(20).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get movies by genre
  static Future<List<MovieModel>> getMoviesByGenre(String genre) async {
    try {
      // Simplify query to avoid index requirement
      final querySnapshot = await _moviesCollection.get();
      final allMovies = _toMovieList(querySnapshot);
      
      // Filter and sort in memory
      final genreMovies = allMovies
          .where((movie) => movie.genres.contains(genre))
          .toList();
      
      // Sort by rating descending
      genreMovies.sort((a, b) => b.rating.compareTo(a.rating));
      
      // Limit to 20
      return genreMovies.take(20).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Search movies by title
  static Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final querySnapshot = await _moviesCollection
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(20)
          .get();
      return _toMovieList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get latest movies
  static Future<List<MovieModel>> getLatestMovies({int limit = 20}) async {
    try {
      final querySnapshot = await _moviesCollection
          .orderBy('releaseYear', descending: true)
          .limit(limit)
          .get();
      return _toMovieList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get top rated movies
  static Future<List<MovieModel>> getTopRatedMovies({int limit = 20}) async {
    try {
      // Simplify query to avoid index requirement
      final querySnapshot = await _moviesCollection.get();
      final allMovies = _toMovieList(querySnapshot);
      
      // Filter and sort in memory
      final topRatedMovies = allMovies
          .where((movie) => movie.rating > 4.0)
          .toList();
      
      // Sort by rating descending
      topRatedMovies.sort((a, b) => b.rating.compareTo(a.rating));
      
      return topRatedMovies.take(limit).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Increment view count
  static Future<void> incrementViewCount(String movieId) async {
    try {
      await _moviesCollection.doc(movieId).update({
        'viewCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update movie rating (this would typically be calculated from reviews)
  static Future<void> updateMovieRating(String movieId, double newRating) async {
    try {
      await _moviesCollection.doc(movieId).update({
        'rating': newRating,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get movies paginated
  static Future<List<MovieModel>> getMoviesPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? genre,
    String? sortBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      Query query = _moviesCollection;
      if (genre != null && genre.isNotEmpty) {
        query = query.where('genres', arrayContains: genre);
      }
      query = query.orderBy(sortBy!, descending: descending);
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      query = query.limit(limit);
      final querySnapshot = await query.get();
      return _toMovieList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }
}
