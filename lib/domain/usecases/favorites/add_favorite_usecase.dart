import '../../entities/sight.dart';
import '../../repositories/favorites_repository.dart';

class AddFavoriteUseCase {
  final FavoritesRepository repository;
  AddFavoriteUseCase(this.repository);

  Future<void> call(Sight sight) {
    return repository.addFavorite(sight);
  }
}
