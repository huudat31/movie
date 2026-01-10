import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/modules/login/cubits/auth_state.dart';
import 'package:movie_app/modules/login/model/user_model.dart';
import 'package:movie_app/services/api/firebase_auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial()) {
    //listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenicated(UserModel.fromFirebaseUser(user)));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        emit(AuthAuthenicated(user));
      } else {
        emit(const AuthError('Sign in failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Sign up with Email & Password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        emit(AuthAuthenicated(user));
      } else {
        emit(const AuthError('Sign up failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        emit(AuthAuthenicated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      emit(AuthLoading());
      final user = await _authService.signInWithFacebook();
      if (user != null) {
        emit(AuthAuthenicated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      emit(AuthLoading());
      await _authService.sendPasswordResetEmail(email);
      emit(AuthPasswordResetEmailSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  bool get isAuthenicated => state is AuthAuthenicated;

  UserModel? get currentUser {
    if (state is AuthAuthenicated) {
      return (state as AuthAuthenicated).user;
    }
    return null;
  }
}
