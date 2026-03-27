// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import '../../services/user_service.dart';
// import '../../data/demo_categories.dart';

// class TransactionList extends StatelessWidget {
//   final List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses;

//   const TransactionList({
//     super.key,
//     required this.expenses,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Recent Transactions',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 16),

//         if (expenses.isEmpty)
//           const Text(
//             'No transactions found',
//             style: TextStyle(color: Colors.white60),
//           ),

//         ...expenses.map(_transactionTile),
//       ],
//     );
//   }

//   Widget _transactionTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
//     final data = doc.data();
//     final isIncome = data['type'] == 'income';

//     final DateTime createdAt =
//         (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

//     final String formattedDate =
//         DateFormat('dd MMM yyyy • hh:mm a').format(createdAt);

//     // ✅ Proper title logic
//     final String displayTitle =
//         (data['title'] != null && data['title'].toString().trim().isNotEmpty)
//             ? data['title']
//             : _getCategoryName(data['category']);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.06),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.white.withOpacity(0.1),
//             child: Icon(
//               isIncome ? Icons.arrow_upward : Icons.arrow_downward,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   displayTitle,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 FutureBuilder<String>(
//                   future: UserService.getUserName(data['paidBy']),
//                   builder: (_, snap) => Text(
//                     'Added by ${snap.data ?? '...'}',
//                     style: const TextStyle(
//                       color: Colors.white60,
//                       fontSize: 11,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   formattedDate,
//                   style: const TextStyle(
//                     color: Colors.white38,
//                     fontSize: 11,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Text(
//             '${isIncome ? '+' : '-'}₹${(data['amount'] as num).toInt()}',
//             style: TextStyle(
//               color: isIncome ? Colors.greenAccent : Colors.redAccent,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ Safe category resolver (no constructor errors now)
//   String _getCategoryName(String categoryId) {
//     try {
//       final category =
//           demoCategories.firstWhere((c) => c.id == categoryId);
//       return category.name;
//     } catch (e) {
//       return categoryId; // fallback
//     }
//   }
// }

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

        ...expenses.map((doc) => _transactionTile(context, doc)),
      ],
    );
  }

  Widget _transactionTile(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final isIncome = data['type'] == 'income';

    final DateTime createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    final String formattedDate =
        DateFormat('dd MMM yyyy • hh:mm a').format(createdAt);

    final String displayTitle =
        (data['title'] != null && data['title'].toString().trim().isNotEmpty)
            ? data['title']
            : _getCategoryName(data['category']);

    return GestureDetector(
      onLongPress: () => _showEditSheet(context, doc),
      child: Container(
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

            // Amount + edit icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}₹${(data['amount'] as num).toInt()}',
                  style: TextStyle(
                    color: isIncome ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showEditSheet(context, doc),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.edit_outlined, size: 11, color: Colors.white38),
                        SizedBox(width: 3),
                        Text(
                          'Edit',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditAmountSheet(doc: doc),
    );
  }

  String _getCategoryName(String categoryId) {
    try {
      final category = demoCategories.firstWhere((c) => c.id == categoryId);
      return category.name;
    } catch (e) {
      return categoryId;
    }
  }
}

// ═══════════════════════════════════════════════════════
// EDIT AMOUNT BOTTOM SHEET
// ═══════════════════════════════════════════════════════
class _EditAmountSheet extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  const _EditAmountSheet({required this.doc});

  @override
  State<_EditAmountSheet> createState() => _EditAmountSheetState();
}

class _EditAmountSheetState extends State<_EditAmountSheet> {
  late TextEditingController _amountController;
  bool _isSaving = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final currentAmount = (widget.doc.data()['amount'] as num).toInt();
    _amountController = TextEditingController(text: currentAmount.toString());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isIncome => widget.doc.data()['type'] == 'income';

  Color get _accentColor =>
      _isIncome ? const Color(0xFF3B82F6) : const Color(0xFFEF4444);

  Future<void> _save() async {
    final text = _amountController.text.trim();
    final parsed = double.tryParse(text);

    if (text.isEmpty || parsed == null || parsed <= 0) {
      setState(() => _hasError = true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.doc.reference.update({'amount': parsed});
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update. Please try again.'),
            backgroundColor: Color(0xFF374151),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Amount',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.close, color: Colors.white70, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Update the amount for this transaction',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),

            // Amount field
            const Text(
              'New Amount',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _hasError
                      ? const Color(0xFFEF4444)
                      : Colors.white.withOpacity(0.1),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) {
                        if (_hasError) setState(() => _hasError = false);
                      },
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
            ),

            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Please enter a valid amount',
                  style: TextStyle(color: _accentColor, fontSize: 12),
                ),
              ),

            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isSaving ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}