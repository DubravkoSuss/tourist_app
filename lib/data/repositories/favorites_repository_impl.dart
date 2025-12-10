import '../../domain/entities/sight.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Sight>> getFavorites() async {
    try {
      final favoriteSights = await localDataSource.getFavoriteSights();

      return favoriteSights.map((data) => Sight(
        id: data['id'] as String,
        name: data['name'] as String,
        imageUrl: data['imageUrl'] as String,
        address: data['address'] as String,
        rating: (data['rating'] as num).toDouble(),
        description: data['description'] as String,
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
      )).toList();
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }

  @override
  Future<void> addFavorite(Sight sight) async {
    try {
      // Convert Sight to Map for storage
      final sightData = {
        'id': sight.id,
        'name': sight.name,
        'imageUrl': sight.imageUrl,
        'address': sight.address,
        'rating': sight.rating,
        'description': sight.description,
        'latitude': sight.latitude,
        'longitude': sight.longitude,
      };

      await localDataSource.addFavorite(sight.id, sightData);
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(String sightId) async {
    try {
      await localDataSource.removeFavorite(sightId);
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(String sightId) async {
    try {
      return await localDataSource.isFavorite(sightId);
    } catch (e) {
      return false;
    }
  }
}