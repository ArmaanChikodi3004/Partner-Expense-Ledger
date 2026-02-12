import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ ADD EXPENSE / INCOME TO PARTNER SUBCOLLECTION
  static Future<String> addExpense({
    required String partnerId,
    required String title,
    required double amount,
    required String type,
    required String category,
    required String paidBy,
    required DateTime createdAt,
  }) async {
    final doc = await _db
        .collection('partners')
        .doc(partnerId)
        .collection('expenses')
        .add({
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'paidBy': paidBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'isDeleted': false,
    });

    return doc.id;
  }

  // ✅ READ EXPENSES FROM SAME SUBCOLLECTION
  static Stream<QuerySnapshot<Map<String, dynamic>>> getExpenses({
    required String partnerId,
  }) {
    return _db
        .collection('partners')
        .doc(partnerId)
        .collection('expenses')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ✅ DELETE FROM SAME SUBCOLLECTION
  static Future<void> deleteExpense({
    required String partnerId,
    required String expenseId,
  }) async {
    await _db
        .collection('partners')
        .doc(partnerId)
        .collection('expenses')
        .doc(expenseId)
        .update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
