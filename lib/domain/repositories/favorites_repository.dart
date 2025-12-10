import '../entities/sight.dart';

abstract class FavoritesRepository {
  Future<List<Sight>> getFavorites();
  Future<void> addFavorite(Sight sight);
  Future<void> removeFavorite(String sightId);
  Future<bool> isFavorite(String sightId);
}
