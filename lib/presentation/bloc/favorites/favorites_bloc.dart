import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/sight.dart';
import '../../../domain/usecases/favorites/get_favorites_usecase.dart';
import '../../../domain/usecases/favorites/add_favorite_usecase.dart';
import '../../../domain/usecases/favorites/remove_favorite_usecase.dart';
import '../../../domain/usecases/favorites/is_favorite_usecase.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}

class AddFavoriteEvent extends FavoritesEvent {
  final Sight sight;

  AddFavoriteEvent(this.sight);

  @override
  List<Object?> get props => [sight];
}

class RemoveFavoriteEvent extends FavoritesEvent {
  final String sightId;

  RemoveFavoriteEvent(this.sightId);

  @override
  List<Object?> get props => [sightId];
}

class CheckFavoriteEvent extends FavoritesEvent {
  final String sightId;

  CheckFavoriteEvent(this.sightId);

  @override
  List<Object?> get props => [sightId];
}

// States
abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Sight> favorites;

  FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

class FavoritesEmpty extends FavoritesState {}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavorites;
  final AddFavoriteUseCase addFavorite;
  final RemoveFavoriteUseCase removeFavorite;
  final IsFavoriteUseCase isFavorite;

  FavoritesBloc({
    required this.getFavorites,
    required this.addFavorite,
    required this.removeFavorite,
    required this.isFavorite,
  }) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await getFavorites();
      if (favorites.isEmpty) {
        emit(FavoritesEmpty());
      } else {
        emit(FavoritesLoaded(favorites));
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onAddFavorite(
    AddFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await addFavorite(event.sight);
      add(LoadFavoritesEvent());
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await removeFavorite(event.sightId);
      add(LoadFavoritesEvent());
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
