import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';
import '../../data/demo_categories.dart';

class TransactionList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses;

  const TransactionList({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        if (expenses.isEmpty)
          const Text(
            'No transactions found',
            style: TextStyle(color: Colors.white60),
          ),

        ...expenses.map(_transactionTile),
      ],
    );
  }

  Widget _transactionTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final isIncome = data['type'] == 'income';

    final DateTime createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    final String formattedDate =
        DateFormat('dd MMM yyyy • hh:mm a').format(createdAt);

    // ✅ Proper title logic
    final String displayTitle =
        (data['title'] != null && data['title'].toString().trim().isNotEmpty)
            ? data['title']
            : _getCategoryName(data['category']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FutureBuilder<String>(
                  future: UserService.getUserName(data['paidBy']),
                  builder: (_, snap) => Text(
                    'Added by ${snap.data ?? '...'}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${isIncome ? '+' : '-'}₹${(data['amount'] as num).toInt()}',
            style: TextStyle(
              color: isIncome ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Safe category resolver (no constructor errors now)
  String _getCategoryName(String categoryId) {
    try {
      final category =
          demoCategories.firstWhere((c) => c.id == categoryId);
      return category.name;
    } catch (e) {
      return categoryId; // fallback
    }
  }
}
