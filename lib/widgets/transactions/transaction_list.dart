import 'package:flutter/material.dart';

// ---------------- DATE FILTER ENUM ----------------
enum DateFilter {
  today,
  last2Days,
  last7Days,
  last15Days,
  lastMonth,
  custom,
}

// ---------------- DEMO TRANSACTION MODEL ----------------
class DemoTransaction {
  final String title;
  final double amount;
  final DateTime date;
  final String user;
  final IconData icon;

  DemoTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.user,
    required this.icon,
  });
}

// ---------------- TRANSACTION LIST ----------------
class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  DateFilter activeFilter = DateFilter.last7Days;
  DateTimeRange? customRange;

  // 🔹 Demo data (Firebase will replace this)
  final List<DemoTransaction> allTransactions = [
    DemoTransaction(
      title: 'Food',
      amount: -250,
      date: DateTime.now(),
      user: 'Armaan',
      icon: Icons.fastfood,
    ),
    DemoTransaction(
      title: 'Rent',
      amount: -5000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      user: 'Waize',
      icon: Icons.home,
    ),
    DemoTransaction(
      title: 'Salary',
      amount: 18000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      user: 'Sam',
      icon: Icons.work,
    ),
  ];

  // ---------------- DATE FILTER LOGIC ----------------
  List<DemoTransaction> get filteredTransactions {
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
        if (customRange == null) return allTransactions;
        return allTransactions.where((t) =>
          t.date.isAfter(customRange!.start) &&
          t.date.isBefore(customRange!.end)
        ).toList();
    }

    return allTransactions.where((t) => t.date.isAfter(start)).toList();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
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

        // -------- TRANSACTION LIST --------
        ...filteredTransactions.map(_transactionTile).toList(),
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
  Widget _transactionTile(DemoTransaction t) {
    final isIncome = t.amount > 0;

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
            child: Icon(t.icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Added by ${t.user}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}₹${t.amount.abs()}',
            style: TextStyle(
              color: isIncome ? Colors.greenAccent : Colors.redAccent,
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
