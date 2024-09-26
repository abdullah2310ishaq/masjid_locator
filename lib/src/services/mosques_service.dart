import 'package:cloud_firestore/cloud_firestore.dart';

class MosqueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch mosque details from Firestore
  Future<Map<String, dynamic>> getMosqueDetails() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('mosques').doc('mosqueId').get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Mosque details not found');
      }
    } catch (e) {
      throw Exception('Error fetching mosque details: $e');
    }
  }

  // Update mosque details in Firestore
  Future<void> updateMosqueDetails(Map<String, dynamic> details) async {
    try {
      await _firestore.collection('mosques').doc('mosqueId').update(details);
    } catch (e) {
      throw Exception('Error updating mosque details: $e');
    }
  }
}
