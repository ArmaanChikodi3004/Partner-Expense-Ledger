import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartnerService {
  static Future<String> createPartner({
    required String name,
    required List<String> memberUids,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-logged-in',
        message: 'User must be logged in to create a partner.',
      );
    }

    try {
      final partnerData = {
        'name': name.trim(),
        'members': memberUids,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('partners')
          .add(partnerData);

      return docRef.id; // Successfully created partner
    } catch (e) {
      throw Exception('Failed to create partner: $e');
    }
  }
}
