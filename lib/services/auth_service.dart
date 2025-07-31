import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'user_service.dart';
import 'category_service.dart';
import 'playlist_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseService.auth;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      print('🔥 Bắt đầu đăng ký user...');
      
      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Auth user created: ${userCredential.user?.uid}');

      // Create user profile in Firestore
      if (userCredential.user != null) {
        print('📝 Tạo user profile...');
        try {
          UserModel userModel = UserModel(
            id: userCredential.user!.uid,
            email: email,
            username: username,
            fullName: fullName,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await UserService.createUserProfile(userModel);
          print('✅ User profile created');
        } catch (profileError) {
          print('⚠️ Warning - Could not create user profile: $profileError');
          // Skip profile creation, return successful auth
          print('🔄 Continuing without profile creation');
        }
      }

      print('✅ Đăng ký hoàn tất');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception(_handleAuthError(e));
    } catch (e) {
      print('❌ Signup Error: $e');
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Đang đăng nhập với email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Đăng nhập thành công: ${userCredential.user?.uid}');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Login Error: ${e.code} - ${e.message}');
      throw Exception(_handleAuthError(e));
    } catch (e) {
      print('❌ Login Error: $e');
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Không thể đăng xuất: $e');
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('Không tìm thấy người dùng');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Update email
  static Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        // Update email in user profile
        await UserService.updateUserProfile(user.uid as UserModel, {'email': newEmail});
      } else {
        throw Exception('Không tìm thấy người dùng');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Re-authenticate user (required for sensitive operations)
  static Future<void> reauthenticateWithPassword(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        throw Exception('Không tìm thấy người dùng');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Delete user account
  static Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user profile from Firestore
        await UserService.deleteUserProfile(user.uid);
        
        // Delete user account
        await user.delete();
      } else {
        throw Exception('Không tìm thấy người dùng');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Check if email is verified
  static bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Reload user to check latest verification status
  static Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      // Ignore errors when reloading user
    }
  }

  // Check if username is available
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      List<UserModel> users = await UserService.searchUsers(username);
      return users.isEmpty || !users.any((user) => user.username.toLowerCase() == username.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  // Handle Firebase Auth errors
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng sử dụng email khác.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Thao tác không được cho phép.';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ.';
      case 'requires-recent-login':
        return 'Thao tác này yêu cầu đăng nhập lại gần đây.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }
}
