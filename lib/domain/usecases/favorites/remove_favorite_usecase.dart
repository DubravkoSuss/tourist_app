import '../../repositories/favorites_repository.dart';

class RemoveFavoriteUseCase {
  final FavoritesRepository repository;
  RemoveFavoriteUseCase(this.repository);

  Future<void> call(String sightId) {
    return repository.removeFavorite(sightId);
  }
}