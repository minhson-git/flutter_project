import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/services/user_service.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

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
      print('Start user registration...');
      
      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Auth user created: ${userCredential.user?.uid}');

      // Create user profile in Firestore
      if (userCredential.user != null) {
        print('Create user profiles...');
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
          print('User profile created');
        } catch (profileError) {
          print('Warning - Could not create user profile: $profileError');
          // Skip profile creation, return successful auth
          print('Continuing without profile creation');
        }
      }

      print('Registration completed');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception(_handleAuthError(e));
    } catch (e) {
      print('Signup Error: $e');
      throw Exception('An unknown error occurred: $e');
    }
  }

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Signing in with email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Login successful: ${userCredential.user?.uid}');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Login Error: ${e.code} - ${e.message}');
      throw Exception(_handleAuthError(e));
    } catch (e) {
      print('Login Error: $e');
      throw Exception('An unknown error occurred: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Cannot log out: $e');
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('User not found');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
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
        throw Exception('User not found');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
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
        throw Exception('User not found');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
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
        throw Exception('User not found');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
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
      throw Exception('An unknown error occurred: $e');
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
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'This email is already in use. Please use another email.';
      case 'invalid-email':
        return 'Invalid email.';
      case 'user-disabled':
        return 'Account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Password is incorrect.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'invalid-credential':
        return 'Invalid login information.';
      case 'requires-recent-login':
        return 'This action requires a recent login.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
