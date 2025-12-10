import '../../repositories/favorites_repository.dart';

class IsFavoriteUseCase {
  final FavoritesRepository repository;
  IsFavoriteUseCase(this.repository);

  Future<bool> call(String sightId) {
    return repository.isFavorite(sightId);
  }
}
