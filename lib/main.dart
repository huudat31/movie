import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_app/modules/home/views/home_screen_new.dart';
import 'package:movie_app/modules/login/cubits/auth_cubit.dart';
import 'package:movie_app/modules/login/cubits/auth_state.dart';
import 'package:movie_app/modules/splashscreen/views/splash_screen.dart';
import 'package:movie_app/services/api/firebase_auth_service.dart';
import 'package:movie_app/services/api/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await dotenv.load(fileName: "assets/.env");
    await _initializeSampleData();
  } catch (e) {
    debugPrint("==========================> /n");
    debugPrint('Error: $e');
  }
  runApp(const MyApp());
}

Future<void> _initializeSampleData() async {
  try {
    final firebaseAuthService = FirestoreService();
    final exitingMovie = await firebaseAuthService.checkIfDataExists();
    if (!exitingMovie) {
      await firebaseAuthService.addSampleData();
    } else {
      debugPrint('Sample data already exists in Firestore.');
    }
  } catch (e) {
    debugPrint('Error initializing sample data: $e');
  }
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
        home: const AuthWrapper(),
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
          return const HomeScreenNew();
        } else if (state is AuthUnauthenticated) {
          return const SplashScreen();
        } else {
          // Loading or Initial state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            ),
          );
        }
      },
    );
  }
}
