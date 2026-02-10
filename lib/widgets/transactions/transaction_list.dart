import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

class TransactionList extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses;
  final ValueChanged<DateFilter>? onDateChange;

  const TransactionList({
    super.key,
    required this.expenses,
    this.onDateChange,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  DateFilter activeFilter = DateFilter.last7Days;
  DateTimeRange? customRange;

  bool _matchesDate(DateTime date) {
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

  @override
  Widget build(BuildContext context) {
    final filteredDocs = widget.expenses.where((doc) {
      final ts = doc['createdAt'] as Timestamp?;
      if (ts == null) return false;
      return _matchesDate(ts.toDate());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------- TITLE + FILTER --------
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

        ...filteredDocs.map(_transactionTile),
      ],
    );
  }

  // ---------------- FILTER DROPDOWN ----------------
  Widget _dateFilterDropdown(BuildContext context) {
    return PopupMenuButton<DateFilter>(
      onSelected: (filter) async {
        if (filter == DateFilter.custom) {
          await _pickCustomRange(context);
        } else {
          setState(() => activeFilter = filter);
          widget.onDateChange?.call(filter);
        }
      },
      color: const Color(0xFF111827),
      itemBuilder: (_) => DateFilter.values.map((f) {
        return PopupMenuItem<DateFilter>(
          value: f,
          child: Text(
            _labelForFilter(f),
            style: const TextStyle(color: Colors.white),
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
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: customRange,
    );

    if (picked != null) {
      setState(() {
        customRange = picked;
        activeFilter = DateFilter.custom;
      });
      widget.onDateChange?.call(DateFilter.custom);
    }
  }

  // ---------------- TRANSACTION TILE (ONLY CHANGE IS HERE) ----------------
  Widget _transactionTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final isIncome = data['type'] == 'income';

    final DateTime createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    final String formattedDate =
        DateFormat('dd MMM yyyy • hh:mm a').format(createdAt);

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

          // ---- TEXT BLOCK ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction name
                Text(
                  data['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                // Added by
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

                // ✅ DATE + TIME (NEW, EXACTLY AS YOU WANT)
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

          // Amount
          Text(
            '${isIncome ? '+' : '-'}₹${(data['amount'] as num).toInt()}',
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
