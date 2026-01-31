import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/user_service.dart';

// ---------------- DATE FILTER ENUM ----------------
enum DateFilter {
  today,
  last2Days,
  last7Days,
  last15Days,
  lastMonth,
  custom,
}

// ---------------- TRANSACTION LIST ----------------
class TransactionList extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses;

  const TransactionList({
    super.key,
    required this.expenses,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  DateFilter activeFilter = DateFilter.last7Days;
  DateTimeRange? customRange;

  // ---------------- DATE FILTER LOGIC ----------------
  bool _matchesDateFilter(DateTime date) {
    final now = DateTime.now();

    DateTime start;
    switch (activeFilter) {
      case DateFilter.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case DateFilter.last2Days:
        start = now.subtract(const Duration(days: 2));
        break;
      case DateFilter.last7Days:
        start = now.subtract(const Duration(days: 7));
        break;
      case DateFilter.last15Days:
        start = now.subtract(const Duration(days: 15));
        break;
      case DateFilter.lastMonth:
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case DateFilter.custom:
        if (customRange == null) return true;
        return !date.isBefore(customRange!.start) &&
            !date.isAfter(customRange!.end);
    }

    return date.isAfter(start);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final filteredDocs = widget.expenses.where((doc) {
      final ts = doc['createdAt'] as Timestamp?;
      if (ts == null) return false;
      return _matchesDateFilter(ts.toDate());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------- TITLE + DROPDOWN --------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            _dateFilterDropdown(context),
          ],
        ),

        const SizedBox(height: 16),

        if (filteredDocs.isEmpty)
          const Text(
            'No transactions found',
            style: TextStyle(color: Colors.white60),
          ),

        ...filteredDocs.map((doc) {
          final data = doc.data();
          final isIncome = data['type'] == 'income';

          return _transactionTile(
            title: data['title'],
            paidBy: data['paidBy'],
            amount: (data['amount'] as num).toInt(),
            isIncome: isIncome,
          );
        }),
      ],
    );
  }

  // ---------------- DATE FILTER DROPDOWN ----------------
  Widget _dateFilterDropdown(BuildContext context) {
    return PopupMenuButton<DateFilter>(
      onSelected: (filter) async {
        if (filter == DateFilter.custom) {
          await _pickCustomRange(context);
        } else {
          setState(() => activeFilter = filter);
        }
      },
      color: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      itemBuilder: (_) => DateFilter.values.map((filter) {
        return PopupMenuItem<DateFilter>(
          value: filter,
          child: Text(
            _labelForFilter(filter),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              _labelForFilter(activeFilter),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CUSTOM DATE PICKER ----------------
  Future<void> _pickCustomRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: customRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              surface: Color(0xFF111827),
            ),
            dialogBackgroundColor: const Color(0xFF0B0E1A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        customRange = picked;
        activeFilter = DateFilter.custom;
      });
    }
  }

  // ---------------- TRANSACTION TILE ----------------
  Widget _transactionTile({
    required String title,
    required String paidBy,
    required int amount,
    required bool isIncome,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FutureBuilder<String>(
                  future: UserService.getUserName(paidBy),
                  builder: (context, snapshot) {
                    final name = snapshot.data ?? '...';
                    return Text(
                      'Added by $name',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}₹$amount',
            style: TextStyle(
              color:
                  isIncome ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- LABEL HELPER ----------------
  String _labelForFilter(DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.last2Days:
        return '2 Days';
      case DateFilter.last7Days:
        return '7 Days';
      case DateFilter.last15Days:
        return '15 Days';
      case DateFilter.lastMonth:
        return 'Month';
      case DateFilter.custom:
        return 'Custom';
    }
  }
}
