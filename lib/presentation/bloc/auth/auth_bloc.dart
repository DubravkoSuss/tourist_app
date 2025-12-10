import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  SignInEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  final String? avatarPath;
  final String? securityQuestion;
  final String? securityAnswer;

  SignUpEvent({
    required this.email,
    required this.password,
    this.name,
    this.avatarPath,
    this.securityQuestion,
    this.securityAnswer,
  });

  @override
  List<Object?> get props => [email, password, name, avatarPath, securityQuestion, securityAnswer];
}

class SignOutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignIn(
      SignInEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await signIn(event.email, event.password);
      emit(Authenticated(user));
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();
      // Remove 'Exception: ' prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignUp(
      SignUpEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await signUp(
        event.email,
        event.password,
        name: event.name,
        avatarPath: event.avatarPath,
        securityQuestion: event.securityQuestion,
        securityAnswer: event.securityAnswer,
      );
      emit(Authenticated(user));
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();

      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignOut(
      SignOutEvent event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await signOut();
      emit(Unauthenticated());
    } catch (e) {
      // Even if sign out fails, treat as unauthenticated
      emit(Unauthenticated());
    }
  }
}