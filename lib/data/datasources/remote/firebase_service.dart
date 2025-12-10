import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all sights from Firebase
  Future<List<Map<String, dynamic>>> getSights() async {
    try {
      print('🔵 Fetching sights from Firebase...');

      final snapshot = await _firestore
          .collection('sights')
          .orderBy('rating', descending: true)
          .get();

      print('✅ Got ${snapshot.docs.length} sights from Firebase');

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      print('❌ Firebase error: $e');
      throw Exception('Failed to fetch sights: $e');
    }
  }

  /// Get single sight by ID
  Future<Map<String, dynamic>> getSightById(String id) async {
    try {
      final doc = await _firestore.collection('sights').doc(id).get();

      if (!doc.exists) {
        throw Exception('Sight not found');
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Failed to fetch sight: $e');
    }
  }

  /// Search sights by name
  Future<List<Map<String, dynamic>>> searchSights(String query) async {
    try {
      final snapshot = await _firestore
          .collection('sights')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search sights: $e');
    }
  }
}