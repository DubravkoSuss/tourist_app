import '../../entities/sight.dart';
import '../../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;
  GetFavoritesUseCase(this.repository);

  Future<List<Sight>> call() {
    return repository.getFavorites();
  }
}
