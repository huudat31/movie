import 'package:movie_app/modules/login/model/user_model.dart';

abstract class AuthState {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenicated extends AuthState {
  final UserModel user;
  const AuthAuthenicated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetEmailSent extends AuthState {}
