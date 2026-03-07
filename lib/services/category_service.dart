import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/custom_category.dart';
import '../data/demo_categories.dart';

class CategoryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col(String partnerId) =>
      _db.collection('partners').doc(partnerId).collection('customCategories');

  // ── ADD ──────────────────────────────────────────
  static Future<String> addCategory({
    required String partnerId,
    required String name,
    required EntryType type,
  }) async {
    final doc = await _col(partnerId).add({
      'name': name,
      'type': type == EntryType.expense ? 'expense' : 'income',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // ── DELETE ───────────────────────────────────────
  static Future<void> deleteCategory({
    required String partnerId,
    required String categoryId,
  }) async {
    await _col(partnerId).doc(categoryId).delete();
  }

  // ── STREAM (realtime) ────────────────────────────
  static Stream<List<CustomCategory>> streamCategories({
    required String partnerId,
  }) {
    return _col(partnerId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              return CustomCategory(
                id: doc.id,
                name: doc['name'] as String,
                type: doc['type'] == 'expense'
                    ? EntryType.expense
                    : EntryType.income,
              );
            }).toList());
  }
}