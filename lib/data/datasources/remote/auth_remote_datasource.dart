import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSource(this.firebaseAuth, this.googleSignIn);

  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  Future<UserModel> signUpWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      return _userFromFirebase(user);
    } catch (e) {
      throw AuthException('Failed to get current user: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In flow...');

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      print('🔵 Google user: ${googleUser?.email}');

      if (googleUser == null) {
        print('🔴 Google sign-in was cancelled by user');
        throw AuthException('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      print('🔵 Getting Google authentication details...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
        '🔵 Got tokens - accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}',
      );

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('🔵 Created Firebase credential');

      // Sign in to Firebase with the Google credential
      print('🔵 Signing in to Firebase...');
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      print(
        '🟢 Firebase sign-in successful! User: ${userCredential.user?.email}',
      );
      print('🟢 User ID: ${userCredential.user?.uid}');

      final userModel = _userFromFirebase(userCredential.user!);
      print('🟢 UserModel created: ${userModel.email}');
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Exception: ${e.code} - ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('🔴 General Exception during Google sign-in: $e');
      throw AuthException('Failed to sign in with Google: $e');
    }
  }

  UserModel _userFromFirebase(firebase_auth.User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
