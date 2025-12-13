import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Data Layer
import 'data/datasources/local/favorites_local_datasource.dart';
import 'data/datasources/remote/firebase_sights_datasource.dart'; // NEW
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/sights_repository_impl.dart';
import 'data/repositories/favorites_repository_impl.dart';

// Domain Layer
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/sights_repository.dart';
import 'domain/repositories/favorites_repository.dart';
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/sights/get_sights_usecase.dart';
import 'domain/usecases/favorites/get_favorites_usecase.dart';
import 'domain/usecases/favorites/add_favorite_usecase.dart';
import 'domain/usecases/favorites/remove_favorite_usecase.dart';
import 'domain/usecases/favorites/is_favorite_usecase.dart';

// Presentation Layer
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/sights/sights_bloc.dart';
import 'presentation/bloc/favorites/favorites_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== API KEY ====================
  // TODO: Get your free API key from https://api.geoapify.com/v2
  const String apiKey = '972e0a10e5c3434a94862beaba653b57';

  // ==================== BLOCS ====================
  sl.registerFactory(() => AuthBloc(
    signIn: sl(),
    signUp: sl(),
    signOut: sl(),
    getCurrentUser: sl(),
  ));

  sl.registerFactory(() => SightsBloc(getSights: sl()));

  sl.registerFactory(() => FavoritesBloc(
    getFavorites: sl(),
    addFavorite: sl(),
    removeFavorite: sl(),
    isFavorite: sl(),
  ));

  // ==================== USE CASES ====================
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => GetSightsUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => AddFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => IsFavoriteUseCase(sl()));

  // ==================== REPOSITORIES ====================
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(),
  );

  // SightsRepository with Firebase support
  sl.registerLazySingleton<SightsRepository>(
        () => SightsRepositoryImpl(
      firebaseDatasource: sl(),  // Inject Firebase datasource
      useMockData: false,        // false = use Firebase, true = use mock
    ),
  );

  sl.registerLazySingleton<FavoritesRepository>(
        () => FavoritesRepositoryImpl(localDataSource: sl()),
  );

  // ==================== DATA SOURCES ====================

  // Firebase Datasource (NEW)
  sl.registerLazySingleton<FirebaseSightsDatasource>(
        () => FirebaseSightsDatasource(),
  );

  sl.registerLazySingleton(() => FavoritesLocalDataSource());


  // HTTP Client (Dio)
  sl.registerLazySingleton(() => Dio());

  // Firestore instance (if you need it elsewhere)
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ==================== LOCAL STORAGE ====================
  // NOTE: Hive boxes are already opened in main.dart

  print('Dependency Injection initialized');
}
