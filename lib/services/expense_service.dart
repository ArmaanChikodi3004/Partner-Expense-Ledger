import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ================= ADD EXPENSE / INCOME =================
  static Future<String> addExpense({
    required String partnerId,
    required String title,
    required double amount,
    required String type, // "expense" | "income"
    required String category,
    required String paidBy,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final expenseJson = {
        "partnerId": partnerId,
        "title": title,
        "amount": amount,
        "type": type,
        "category": category,
        "paidBy": paidBy,
        "createdBy": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
        "isDeleted": false,
      };

      final docRef =
          await _db.collection('expenses').add(expenseJson);

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // ================= GET EXPENSES BY PARTNER =================
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getExpenses({
  //   required String partnerId,
  // }) {
  //   return _db
  //       .collection('expenses')
  //       .where('partnerId', isEqualTo: partnerId)
  //       .where('isDeleted', isEqualTo: false)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots();
  // }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getExpenses({
    required String partnerId,
  }) {
    return _db
        .collection("expenses")
        .where("partnerId", isEqualTo: partnerId)
        .where("isDeleted", isEqualTo: false)
        .orderBy("partnerId")
        .orderBy("isDeleted")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // ================= SOFT DELETE =================
  static Future<void> deleteExpense(String expenseId) async {
    await _db.collection('expenses').doc(expenseId).update({
      "isDeleted": true,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}
