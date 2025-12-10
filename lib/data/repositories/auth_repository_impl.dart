import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hive/hive.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  domain.User? _currentUser;
  late Box _usersBox;
  late Box _sessionBox;

  AuthRepositoryImpl({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance {
    _usersBox = Hive.box('users');
    _sessionBox = Hive.box('session');

    // Check if user is already signed in with Firebase
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      final userData = _usersBox.get(firebaseUser.email);
      _currentUser = domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: userData?['name'] ?? firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
        fullName: userData?['full_name'],
        dateOfBirth: userData?['date_of_birth'],
        residence: userData?['residence'],
        avatarPath: userData?['avatar_path'],
      );
    }
  }

  @override
  Future<domain.User> signIn(String email, String password) async {
    try {
      // Sign in with Firebase Authentication
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // Load additional user data from Hive
      final userData = _usersBox.get(email);

      // Create our User entity from Firebase user + Hive data
      _currentUser = domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: userData?['name'] ?? firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
        fullName: userData?['full_name'],
        dateOfBirth: userData?['date_of_birth'],
        residence: userData?['residence'],
        avatarPath: userData?['avatar_path'],
      );

      // Save session locally (optional - Firebase handles this automatically)
      await _sessionBox.put('current_user_email', email);

      return _currentUser!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Convert Firebase errors to user-friendly messages
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'wrong-password':
          throw Exception('Invalid email or password');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later');
        default:
          throw Exception('Authentication failed. Please try again');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  @override
  Future<domain.User> signUp(
      String email,
      String password, {
        String? name,
        String? avatarPath,
        String? securityQuestion,
        String? securityAnswer,
      }) async {
    try {
      // Create user with Firebase Authentication
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;
      final username = name ?? email.split('@')[0];

      // Update Firebase profile with display name
      await firebaseUser.updateDisplayName(username);

      // Store additional user data in Hive (since Firebase Auth only stores email/password)
      final userData = {
        'id': firebaseUser.uid,
        'email': email,
        'name': username,
        'avatar_path': avatarPath,
        'security_question': securityQuestion,
        'security_answer': securityAnswer?.toLowerCase().trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _usersBox.put(email, userData);

      // Create our User entity
      _currentUser = domain.User(
        id: firebaseUser.uid,
        email: email,
        name: username,
        fullName: null,
        dateOfBirth: null,
        residence: null,
        avatarPath: avatarPath,
      );

      // Save session
      await _sessionBox.put('current_user_email', email);

      return _currentUser!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Convert Firebase errors to user-friendly messages
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password must be at least 8 characters');
        case 'email-already-in-use':
          throw Exception('An account already exists with this email');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled');
        default:
          throw Exception('Registration failed. Please try again');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Clear local session
      _currentUser = null;
      await _sessionBox.clear();
    } catch (e) {
      throw Exception('Failed to sign out');
    }
  }

  @override
  domain.User? getCurrentUser() {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      // Get additional data from Hive if available
      final userData = _usersBox.get(firebaseUser.email);

      return domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: userData?['name'] ?? firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
        fullName: userData?['full_name'],
        dateOfBirth: userData?['date_of_birth'],
        residence: userData?['residence'],
        avatarPath: userData?['avatar_path'],
      );
    }

    return null;
  }

  @override
  Stream<domain.User?> get authStateChanges {
    // Listen to Firebase auth state changes and convert to our User entity
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser != null) {
        // Get additional data from Hive if available
        final userData = _usersBox.get(firebaseUser.email);

        return domain.User(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: userData?['name'] ?? firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
          fullName: userData?['full_name'],
          dateOfBirth: userData?['date_of_birth'],
          residence: userData?['residence'],
          avatarPath: userData?['avatar_path'],
        );
      }
      return null;
    });
  }
}