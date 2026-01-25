import 'package:flutter/material.dart';
import '../../data/demo_entries.dart';
import '../../widgets/reports/six_month_bar_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  // ---------- Helpers ----------
  String formatCurrency(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // ---------- THIS MONTH STATS ----------
    final thisMonthEntries = demoEntries.where(
      (e) => e.date.month == now.month && e.date.year == now.year,
    );

    final double income = thisMonthEntries
        .where((e) => e.type == EntryType.income)
        .fold(0, (sum, e) => sum + e.amount);

    final double expense = thisMonthEntries
        .where((e) => e.type == EntryType.expense)
        .fold(0, (sum, e) => sum + e.amount);

    final double balance = income - expense;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- TITLE ----------------
          const Text(
            'Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // ---------------- THIS MONTH CARD ----------------
          _animatedSection(
            child: _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _statTile(
                        label: 'Income',
                        value: formatCurrency(income),
                        color: const Color(0xFF6366F1),
                      ),
                      _statTile(
                        label: 'Expenses',
                        value: formatCurrency(expense),
                        color: const Color(0xFFEC4899),
                      ),
                      _statTile(
                        label: 'Net Balance',
                        value: formatCurrency(balance),
                        color: balance >= 0
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                      ),
                      _statTile(
                        label: 'Transactions',
                        value: thisMonthEntries.length.toString(),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ---------------- 6 MONTH OVERVIEW ----------------
          _animatedSection(
            child: const SixMonthBarChart(),
          ),

          const SizedBox(height: 24),

          // ---------------- TOP SPENDING ----------------
          _animatedSection(
            child: _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Spending Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._topSpendingWidgets(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 120), // space for bottom nav
        ],
      ),
    );
  }

  // ---------- TOP SPENDING LOGIC ----------
  List<Widget> _topSpendingWidgets() {
    final expenseEntries =
        demoEntries.where((e) => e.type == EntryType.expense).toList();

    final Map<String, double> totals = {};

    for (var e in expenseEntries) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxAmount = sorted.isEmpty ? 1 : sorted.first.value;

    return sorted.take(5).map((entry) {
      final percent = entry.value / maxAmount;

      final sample = expenseEntries.firstWhere(
        (e) => e.category == entry.key,
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(sample.categoryIcon),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  formatCurrency(entry.value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor:
                    AlwaysStoppedAnimation<Color>(sample.color),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ---------- UI HELPERS ----------
  Widget _animatedSection({required Widget child}) {
    return AnimatedSlide(
      offset: const Offset(0, 0.05),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 400),
        child: child,
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
