import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signIn(String email, String password);
  Future<User> signUp(
      String email,
      String password, {
        String? name,
        String? avatarPath,
        String? securityQuestion,
        String? securityAnswer,
      });
  Future<void> signOut();
  User? getCurrentUser();
  Stream<User?> get authStateChanges;
}

