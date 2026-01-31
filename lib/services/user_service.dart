import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;

  static final Map<String, String> _cache = {};

  static Future<String> getUserName(String uid) async {
    if (_cache.containsKey(uid)) {
      return _cache[uid]!;
    }

    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      return 'Unknown';
    }

    final name = doc.data()?['name'] ?? 'Unknown';
    _cache[uid] = name;
    return name;
  }
}
