import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/modules/login/cubits/auth_cubit.dart';
import 'package:movie_app/modules/login/cubits/auth_state.dart';
import 'package:movie_app/modules/login/views/home_screen.dart';
import 'package:movie_app/modules/login/views/login_screen.dart';
import 'package:movie_app/modules/splashscreen/views/splash_screen.dart';
import 'package:movie_app/service/api/firebase_auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(FirebaseAuthService()),
      child: MaterialApp(
        title: 'Movie+ Auth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenicated) {
          return const HomeScreen();
        } else if (state is AuthUnauthenticated) {
          return const LoginScreen();
        } else {
          // Loading or Initial state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
