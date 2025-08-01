
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';
import '../models/playlist_model.dart';
import 'firebase_service.dart';


class PlaylistService {
  static final CollectionReference _playlistsCollection = FirebaseService.playlistsCollection;

  // Helper: convert QuerySnapshot to List<PlaylistModel>
  static List<PlaylistModel> _toPlaylistList(QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((doc) => PlaylistModel.fromFirestore(doc))
        .toList();
  }

  // Helper: handle error
  static Exception _handleError(dynamic e) => Exception(FirebaseService.handleFirestoreError(e));

  // Create new playlist
  static Future<String> createPlaylist(PlaylistModel playlist) async {
    try {
      DocumentReference docRef = await _playlistsCollection.add(playlist.toFirestore());
      return docRef.id;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get user's playlists
  static Future<List<PlaylistModel>> getUserPlaylists(String userId) async {
    try {
      final querySnapshot = await _playlistsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('isDefault', descending: true)
          .orderBy('createdAt', descending: true)
          .get();
      return _toPlaylistList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get public playlists
  static Future<List<PlaylistModel>> getPublicPlaylists({int limit = 20}) async {
    try {
      final querySnapshot = await _playlistsCollection
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return _toPlaylistList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get playlist by ID
  static Future<PlaylistModel?> getPlaylistById(String playlistId) async {
    try {
      final doc = await _playlistsCollection.doc(playlistId).get();
      return doc.exists ? PlaylistModel.fromFirestore(doc) : null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Add movie to playlist
  static Future<void> addMovieToPlaylist(String playlistId, String movieId) async {
    try {
      await _playlistsCollection.doc(playlistId).update({
        'movieIds': FieldValue.arrayUnion([movieId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Remove movie from playlist
  static Future<void> removeMovieFromPlaylist(String playlistId, String movieId) async {
    try {
      await _playlistsCollection.doc(playlistId).update({
        'movieIds': FieldValue.arrayRemove([movieId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  static Future<List<MovieModel>> getMoviesInPlaylist(String playlistId) async {
    try {
      final playlistDoc = await _playlistsCollection.doc(playlistId).get();
      if (!playlistDoc.exists) {
        return [];
      }

      final playlist = PlaylistModel.fromFirestore(playlistDoc);
      if (playlist.movieIds.isEmpty) {
        return [];
      }

      // Use MovieService to get movies by IDs
      // Import MovieService at the top of the file
      final movieService = FirebaseService.moviesCollection;
      final movies = <MovieModel>[];

      // Firestore 'in' query has a limit of 10 items, so we need to batch the requests
      for (int i = 0; i < playlist.movieIds.length; i += 10) {
        final batch = playlist.movieIds.sublist(
            i,
            (i + 10 > playlist.movieIds.length) ? playlist.movieIds.length : i + 10
        );

        final querySnapshot = await movieService
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final batchMovies = querySnapshot.docs
            .map((doc) => MovieModel.fromFirestore(doc))
            .toList();

        movies.addAll(batchMovies);
      }

      // Sort movies by the order they appear in the playlist
      movies.sort((a, b) {
        final indexA = playlist.movieIds.indexOf(a.id!);
        final indexB = playlist.movieIds.indexOf(b.id!);
        return indexA.compareTo(indexB);
      });

      return movies;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Update playlist with Map
  static Future<void> updatePlaylistWithMap(String playlistId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _playlistsCollection.doc(playlistId).update(updates);
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Update playlist with PlaylistModel
  static Future<void> updatePlaylist(PlaylistModel playlist) async {
    try {
      Map<String, dynamic> data = {
        'name': playlist.name,
        'description': playlist.description,
        'isPublic': playlist.isPublic,
        'updatedAt': Timestamp.fromDate(playlist.updatedAt),
      };
      
      await _playlistsCollection.doc(playlist.id).update(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete playlist
  static Future<void> deletePlaylist(String playlistId) async {
    try {
      await _playlistsCollection.doc(playlistId).delete();
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Create default playlists for user
  static Future<void> createDefaultPlaylists(String userId) async {
    try {
      List<Map<String, dynamic>> defaultPlaylists = [
        {
          'name': 'Watch later',
          'description': 'List of movies to watch later',
          'isDefault': true,
          'isPublic': false,
        },
        {
          'name': 'Favorite',
          'description': 'Favorite movie list',
          'isDefault': true,
          'isPublic': false,
        },
      ];

      for (Map<String, dynamic> playlistData in defaultPlaylists) {
        // Check if default playlist already exists
        QuerySnapshot existingPlaylist = await _playlistsCollection
            .where('userId', isEqualTo: userId)
            .where('name', isEqualTo: playlistData['name'])
            .where('isDefault', isEqualTo: true)
            .limit(1)
            .get();

        if (existingPlaylist.docs.isEmpty) {
          PlaylistModel playlist = PlaylistModel(
            userId: userId,
            name: playlistData['name'],
            description: playlistData['description'],
            isDefault: playlistData['isDefault'],
            isPublic: playlistData['isPublic'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await createPlaylist(playlist);
        }
      }
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get user's "Watch Later" playlist
  static Future<PlaylistModel?> getWatchLaterPlaylist(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _playlistsCollection
          .where('userId', isEqualTo: userId)
          .where('name', isEqualTo: 'Xem sau')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return PlaylistModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get user's "Favorites" playlist
  static Future<PlaylistModel?> getFavoritesPlaylist(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _playlistsCollection
          .where('userId', isEqualTo: userId)
          .where('name', isEqualTo: 'Yêu thích')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return PlaylistModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Add movie to "Watch Later"
  static Future<void> addToWatchLater(String userId, String movieId) async {
    try {
      PlaylistModel? playlist = await getWatchLaterPlaylist(userId);
      if (playlist == null) {
        await createDefaultPlaylists(userId);
        playlist = await getWatchLaterPlaylist(userId);
      }
      
      if (playlist != null) {
        await addMovieToPlaylist(playlist.id!, movieId);
      }
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Add movie to "Favorites"
  static Future<void> addToFavorites(String userId, String movieId) async {
    try {
      PlaylistModel? playlist = await getFavoritesPlaylist(userId);
      if (playlist == null) {
        await createDefaultPlaylists(userId);
        playlist = await getFavoritesPlaylist(userId);
      }
      
      if (playlist != null) {
        await addMovieToPlaylist(playlist.id!, movieId);
      }
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Remove from "Watch Later"
  static Future<void> removeFromWatchLater(String userId, String movieId) async {
    try {
      PlaylistModel? playlist = await getWatchLaterPlaylist(userId);
      if (playlist != null) {
        await removeMovieFromPlaylist(playlist.id!, movieId);
      }
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Remove from "Favorites"
  static Future<void> removeFromFavorites(String userId, String movieId) async {
    try {
      PlaylistModel? playlist = await getFavoritesPlaylist(userId);
      if (playlist != null) {
        await removeMovieFromPlaylist(playlist.id!, movieId);
      }
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Check if movie is in playlist
  static Future<bool> isMovieInPlaylist(String playlistId, String movieId) async {
    try {
      PlaylistModel? playlist = await getPlaylistById(playlistId);
      return playlist?.movieIds.contains(movieId) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Share playlist with users
  static Future<void> sharePlaylist(String playlistId, List<String> userIds) async {
    try {
      await _playlistsCollection.doc(playlistId).update({
        'sharedWith': FieldValue.arrayUnion(userIds),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Unshare playlist with users
  static Future<void> unsharePlaylist(String playlistId, List<String> userIds) async {
    try {
      await _playlistsCollection.doc(playlistId).update({
        'sharedWith': FieldValue.arrayRemove(userIds),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Get playlists shared with user
  static Future<List<PlaylistModel>> getSharedPlaylists(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _playlistsCollection
          .where('sharedWith', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PlaylistModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception(FirebaseService.handleFirestoreError(e));
    }
  }

  // Search playlists
  static Future<List<PlaylistModel>> searchPublicPlaylists(String query) async {
    try {
      final querySnapshot = await _playlistsCollection
          .where('isPublic', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('name')
          .limit(20)
          .get();
      return _toPlaylistList(querySnapshot);
    } catch (e) {
      throw _handleError(e);
    }
  }
}
