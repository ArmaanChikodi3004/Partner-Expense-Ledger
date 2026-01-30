import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartnerService {
  static Future<String> createPartner({
    required String name,
    required List<String> memberUids,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final uid = user.uid;

      final partnerJson = {
        "name": name,
        "members": memberUids,
        "createdBy": uid,
        "createdAt": FieldValue.serverTimestamp(),
        "isActive": true,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('partners')
          .add(partnerJson);

      return docRef.id; // ✅ confirms success
    } catch (e) {
      rethrow; // 🔥 propagate error to UI
    }
  }
}
