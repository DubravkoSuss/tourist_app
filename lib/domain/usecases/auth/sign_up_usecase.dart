import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<User> call(
      String email,
      String password, {
        String? name,
        String? avatarPath,
        String? securityQuestion,
        String? securityAnswer,
      }) {
    final normalizedEmail = email.trim().toLowerCase();
    return repository.signUp(
      normalizedEmail,
      password,
      name: name,
      avatarPath: avatarPath,
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer,
    );
  }
}