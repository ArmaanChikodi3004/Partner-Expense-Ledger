import 'package:flutter/material.dart';
import '../../data/demo_entries.dart';
import '../../widgets/reports/six_month_bar_chart.dart';
import '../../models/report_range.dart';

enum DateChip { today, thisMonth, lastMonth, custom }
enum ChartMode { sixMonths, singleMonth }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? selectedRange;
  DateChip activeDateChip = DateChip.thisMonth;

  ChartMode chartMode = ChartMode.sixMonths;
  int selectedMonth = DateTime.now().month;

  String formatCurrency(double v) => '₹${v.toStringAsFixed(0)}';

  // ---------------- DATE RANGE LOGIC ----------------

  DateTimeRange _rangeForChip(DateChip chip) {
    final now = DateTime.now();

    switch (chip) {
      case DateChip.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case DateChip.lastMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        );
      default:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
    }
  }

  List<DemoEntry> _filteredEntries() {
    final range = selectedRange ?? _rangeForChip(activeDateChip);
    return demoEntries.where((e) =>
        e.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
        e.date.isBefore(range.end.add(const Duration(days: 1)))).toList();
  }

  double _sum(List<DemoEntry> list, EntryType type) =>
      list.where((e) => e.type == type).fold(0.0, (s, e) => s + e.amount);

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries();
    final income = _sum(entries, EntryType.income);
    final expense = _sum(entries, EntryType.expense);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          const SizedBox(height: 16),

          _dateChips(context),

          const SizedBox(height: 16),

          _summaryCard(income, expense, income - expense, entries.length),

          const SizedBox(height: 24),

          _chartChips(context),

          const SizedBox(height: 16),

          SixMonthBarChart(
            entries: entries,
            range: chartMode == ChartMode.sixMonths
                ? ReportRange.sixMonths
                : ReportRange.thisMonth,
            selectedMonth: selectedMonth,
          ),

          const SizedBox(height: 24),

          _topSpendingSection(entries),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ---------------- DARK CHIP ----------------

  Widget _darkChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6366F1) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active) const Icon(Icons.check, size: 14, color: Colors.white),
            if (active) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DATE CHIPS ----------------

  Widget _dateChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: DateChip.values.map((c) {
        return _darkChip(
          label: _dateLabel(c),
          active: activeDateChip == c,
          onTap: () async {
            if (c == DateChip.custom) {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (_, child) =>
                    Theme(data: ThemeData.dark(), child: child!),
              );
              if (picked != null) {
                setState(() {
                  selectedRange = picked;
                  activeDateChip = c;
                });
              }
            } else {
              setState(() {
                activeDateChip = c;
                selectedRange = _rangeForChip(c);
              });
            }
          },
        );
      }).toList(),
    );
  }

  String _dateLabel(DateChip c) {
    switch (c) {
      case DateChip.today:
        return 'Today';
      case DateChip.thisMonth:
        return 'This Month';
      case DateChip.lastMonth:
        return 'Last Month';
      case DateChip.custom:
        return 'Custom';
    }
  }

  // ---------------- CHART CHIPS ----------------

  Widget _chartChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        _darkChip(
          label: '6 Months',
          active: chartMode == ChartMode.sixMonths,
          onTap: () => setState(() => chartMode = ChartMode.sixMonths),
        ),
        _darkChip(
          label: 'Pick Month',
          active: chartMode == ChartMode.singleMonth,
          onTap: () async {
            final picked = await showModalBottomSheet<int>(
              context: context,
              backgroundColor: const Color(0xFF111827),
              builder: (_) => _monthPicker(),
            );
            if (picked != null) {
              setState(() {
                chartMode = ChartMode.singleMonth;
                selectedMonth = picked;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _monthPicker() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (_, i) {
        return GestureDetector(
          onTap: () => Navigator.pop(context, i + 1),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Text(
              const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][i],
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // ---------------- SUMMARY ----------------

  Widget _summaryCard(double income, double expense, double balance, int count) {
    return _glassCard(
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _stat('Income', formatCurrency(income), const Color(0xFF6366F1)),
          _stat('Expenses', formatCurrency(expense), const Color(0xFFEC4899)),
          _stat(
            'Net Balance',
            formatCurrency(balance),
            balance >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          ),
          _stat('Transactions', '$count', Colors.white),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------- TOP SPENDING ----------------

  Widget _topSpendingSection(List<DemoEntry> entries) {
    final expenses = entries.where((e) => e.type == EntryType.expense).toList();
    if (expenses.isEmpty) return const SizedBox();

    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final max = sorted.first.value;

    return _glassCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Spending Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 16),

          ...sorted.take(5).map((e) {
            final sample = expenses.firstWhere((x) => x.category == e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(sample.categoryIcon),
                          const SizedBox(width: 8),
                          Text(e.key, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      Text(formatCurrency(e.value),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: e.value / max,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(sample.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _glassCard(Widget child) {
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
}
