import 'package:hive/hive.dart';

class FavoritesLocalDataSource {
  static const String boxName = 'favorites';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  /// Get all favorite IDs
  Future<List<String>> getFavoriteIds() async {
    final box = await _getBox();
    final favoriteIds = box.get('favorite_ids', defaultValue: <String>[]);
    return List<String>.from(favoriteIds);
  }

  /// Add a favorite sight (stores the full sight data)
  Future<void> addFavorite(String sightId, Map<String, dynamic> sightData) async {
    final box = await _getBox();

    // Store the sight data
    await box.put('sight_$sightId', sightData);

    // Add to favorites list
    final favoriteIds = await getFavoriteIds();
    if (!favoriteIds.contains(sightId)) {
      favoriteIds.add(sightId);
      await box.put('favorite_ids', favoriteIds);
    }
  }

  /// Remove a favorite
  Future<void> removeFavorite(String sightId) async {
    final box = await _getBox();

    // Remove the sight data
    await box.delete('sight_$sightId');

    // Remove from favorites list
    final favoriteIds = await getFavoriteIds();
    favoriteIds.remove(sightId);
    await box.put('favorite_ids', favoriteIds);
  }

  /// Check if a sight is favorited
  Future<bool> isFavorite(String sightId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(sightId);
  }

  /// Get all favorite sights (returns the stored data)
  Future<List<Map<String, dynamic>>> getFavoriteSights() async {
    final box = await _getBox();
    final favoriteIds = await getFavoriteIds();

    final sights = <Map<String, dynamic>>[];
    for (final id in favoriteIds) {
      final sightData = box.get('sight_$id');
      if (sightData != null) {
        sights.add(Map<String, dynamic>.from(sightData));
      }
    }

    return sights;
  }
}