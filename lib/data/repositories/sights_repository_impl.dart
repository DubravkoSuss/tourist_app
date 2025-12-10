import '../../domain/entities/sight.dart';
import '../../domain/repositories/sights_repository.dart';
import '../datasources/remote/firebase_sights_datasource.dart';
import '../datasources/local/mock_sights_data.dart';

class SightsRepositoryImpl implements SightsRepository {
  final FirebaseSightsDatasource? firebaseDatasource;
  final bool useMockData;

  SightsRepositoryImpl({
    this.firebaseDatasource,
    this.useMockData = false,
  });

  @override
  Future<List<Sight>> getSights() async {
    print('🔵 getSights() called');
    print('🔵 useMockData: $useMockData');

    if (useMockData || firebaseDatasource == null) {
      print('🟡 Using mock data');
      return _getMockSights();
    }

    try {
      print('🔵 Fetching from Firebase...');
      final sightsData = await firebaseDatasource!.getSights();
      print('✅ Got ${sightsData.length} sights from Firebase');

      return sightsData.map((data) => Sight(
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
      print('🔴 Firebase failed: $e, using mock data');
      return _getMockSights();
    }
  }

  @override
  Future<Sight> getSightById(String id) async {
    if (useMockData || firebaseDatasource == null) {
      return _getMockSightById(id);
    }

    try {
      final data = await firebaseDatasource!.getSightById(id);

      return Sight(
        id: data['id'] as String,
        name: data['name'] as String,
        imageUrl: data['imageUrl'] as String,
        address: data['address'] as String,
        rating: (data['rating'] as num).toDouble(),
        description: data['description'] as String,
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
      );
    } catch (e) {
      print('🔴 Firebase failed: $e');
      return _getMockSightById(id);
    }
  }

  @override
  Future<void> uploadMockDataToFirebase() async {
    if (firebaseDatasource == null) {
      throw Exception('Firebase datasource not available');
    }
  }


  Future<List<Sight>> _getMockSights() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final sightsData = MockSightsData.zagrebSights;
      return sightsData.map((data) => Sight(
        id: data['id'],
        name: data['name'],
        imageUrl: data['imageUrl'],
        address: data['address'],
        rating: data['rating'].toDouble(),
        description: data['description'],
        latitude: data['latitude'].toDouble(),
        longitude: data['longitude'].toDouble(),
      )).toList();
    } catch (e) {
      throw Exception('Failed to fetch sights: $e');
    }
  }

  Future<Sight> _getMockSightById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final sightData = MockSightsData.zagrebSights.firstWhere(
            (sight) => sight['id'] == id,
      );

      return Sight(
        id: sightData['id'],
        name: sightData['name'],
        imageUrl: sightData['imageUrl'],
        address: sightData['address'],
        rating: sightData['rating'].toDouble(),
        description: sightData['description'],
        latitude: sightData['latitude'].toDouble(),
        longitude: sightData['longitude'].toDouble(),
      );
    } catch (e) {
      throw Exception('Failed to fetch sight details: $e');
    }
  }
}