import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance
  static FirebaseFirestore get firestore => _firestore;
  
  // Auth instance
  static FirebaseAuth get auth => _auth;

  // Current user
  static User? get currentUser => _auth.currentUser;

  // Collection references
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get moviesCollection => _firestore.collection('movies');
  static CollectionReference get categoriesCollection => _firestore.collection('categories');
  static CollectionReference get watchHistoryCollection => _firestore.collection('watch_history');
  static CollectionReference get reviewsCollection => _firestore.collection('reviews');
  static CollectionReference get playlistsCollection => _firestore.collection('playlists');

  // Helper method to handle Firestore exceptions
  static String handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'not-found':
          return 'Data does not exist.';
        case 'already-exists':
          return 'Data already exists.';
        case 'unavailable':
          return 'Service is currently unavailable. Please try again.';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unknown error occurred.';
  }
}
