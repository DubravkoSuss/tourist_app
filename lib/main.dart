import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tourist_guide_app/presentation/screens/home/home_screen.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/sights/sights_bloc.dart';
import 'presentation/bloc/favorites/favorites_bloc.dart';
import 'presentation/screens/auth/sign_in_screen.dart';

void main() async {
  print('🟢 1. Starting app...');

  WidgetsFlutterBinding.ensureInitialized();
  print('🟢 2. Flutter binding initialized');

  await Hive.initFlutter();
  print('🟢 3. Hive initialized');

  await Hive.openBox('favorites');
  print('🟢 4. Favorites box opened');

  await Hive.openBox('users');
  print('🟢 5. Users box opened');

  await Hive.openBox('session');
  print('🟢 6. Session box opened');

  await Hive.openBox('messages');
  print('🟢 7. Messages box opened');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🟢 8. Firebase initialized successfully');
  } catch (e) {
    print('🔴 Firebase initialization failed: $e');
  }

  try {
    await di.init();
    print('🟢 9. Dependency injection initialized');
  } catch (e) {
    print('🔴 Dependency injection failed: $e');
  }

  print('🟢 10. Running app...');
  runApp(const TouristGuideApp());
}

class TouristGuideApp extends StatelessWidget {
  const TouristGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🟢 11. Building TouristGuideApp');

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            print('🟢 12. Creating AuthBloc');
            return di.sl<AuthBloc>();
          },
        ),
        BlocProvider(
          create: (_) {
            print('🟢 13. Creating SightsBloc');
            return di.sl<SightsBloc>();
          },
        ),
        BlocProvider(
          create: (_) {
            print('🟢 14. Creating FavoritesBloc');
            return di.sl<FavoritesBloc>()..add(LoadFavoritesEvent());
          },
        ),
      ],
      child: MaterialApp(
        title: 'Tourist Guide',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            print('🟢 15. StreamBuilder state: ${snapshot.connectionState}');
            print('🟢 16. Has data: ${snapshot.hasData}');
            print('🟢 17. Has error: ${snapshot.hasError}');

            if (snapshot.hasError) {
              print('🔴 Auth stream error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              print('🟡 Waiting for auth state...');
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              print('🟢 18. User logged in, showing HomeScreen');
              return const HomeScreen();
            }

            print('🟢 19. No user, showing SignInScreen');
            return const SignInScreen();
          },
        ),
      ),
    );
  }
}