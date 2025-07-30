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
          return 'Bạn không có quyền thực hiện hành động này.';
        case 'not-found':
          return 'Dữ liệu không tồn tại.';
        case 'already-exists':
          return 'Dữ liệu đã tồn tại.';
        case 'unavailable':
          return 'Dịch vụ hiện không khả dụng. Vui lòng thử lại.';
        default:
          return 'Đã xảy ra lỗi: ${error.message}';
      }
    }
    return 'Đã xảy ra lỗi không xác định.';
  }
}
