import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSightsDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tourist_sights';

  /// GET all sights from Firebase
  Future<List<Map<String, dynamic>>> getSights() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting sights from Firebase: $e');
      rethrow;
    }
  }

  // GET single sight by ID
  Future<Map<String, dynamic>> getSightById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        throw Exception('Sight not found');
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      print('❌ Error getting sight by ID from Firebase: $e');
      rethrow;
    }
  }
}