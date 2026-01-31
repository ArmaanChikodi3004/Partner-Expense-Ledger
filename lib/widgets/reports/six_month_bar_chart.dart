import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/demo_entries.dart';
import '../../models/report_range.dart';

class SixMonthBarChart extends StatelessWidget {
  final List<DemoEntry> entries;
  final ReportRange range;
  final int? selectedMonth;

  const SixMonthBarChart({
    super.key,
    required this.entries,
    required this.range,
    this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final data = _buildChartData();

    final maxY = data
            .map((e) => e.income > e.expense ? e.income : e.expense)
            .fold<double>(0, (a, b) => a > b ? a : b) *
        1.2;

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY == 0 ? 100 : maxY,
                barGroups: _barGroups(data),
                titlesData: _titles(data),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: _tooltip(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(color: Color(0xFF6366F1), label: 'Income'),
              SizedBox(width: 20),
              _LegendDot(color: Color(0xFFEC4899), label: 'Expense'),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- DATA ----------------

  List<_ChartUnit> _buildChartData() {
    final now = DateTime.now();

    // 🔹 6 MONTH VIEW
    if (range == ReportRange.sixMonths) {
      return List.generate(6, (i) {
        final date = DateTime(now.year, now.month - (5 - i), 1);
        return _fromEntries(
          label: _monthName(date.month),
          entries: entries.where(
            (e) => e.date.month == date.month && e.date.year == date.year,
          ),
        );
      });
    }

    // 🔹 SINGLE MONTH → WEEK-WISE (FIXED)
    if (range == ReportRange.thisMonth && selectedMonth != null) {
      final year = now.year;
      final firstDay = DateTime(year, selectedMonth!, 1);
      final lastDay = DateTime(year, selectedMonth! + 1, 0);

      final weeks = <_ChartUnit>[];
      DateTime cursor = firstDay;
      int weekIndex = 1;

      while (cursor.isBefore(lastDay) || cursor.isAtSameMomentAs(lastDay)) {
        final weekStart = cursor;
        final weekEnd = cursor.add(const Duration(days: 6));

        weeks.add(
          _fromEntries(
            label: 'W$weekIndex',
            entries: entries.where(
              (e) =>
                  !e.date.isBefore(weekStart) &&
                  !e.date.isAfter(weekEnd),
            ),
          ),
        );

        cursor = cursor.add(const Duration(days: 7));
        weekIndex++;
      }

      return weeks;
    }

    return [];
  }

  _ChartUnit _fromEntries({
    required String label,
    required Iterable<DemoEntry> entries,
  }) {
    final income = entries
        .where((e) => e.type == EntryType.income)
        .fold(0.0, (s, e) => s + e.amount);

    final expense = entries
        .where((e) => e.type == EntryType.expense)
        .fold(0.0, (s, e) => s + e.amount);

    return _ChartUnit(label: label, income: income, expense: expense);
  }

  // ---------------- UI ----------------

  List<BarChartGroupData> _barGroups(List<_ChartUnit> data) {
    return List.generate(data.length, (i) {
      final d = data[i];
      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: d.income,
            width: 14,
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFF6366F1),
          ),
          BarChartRodData(
            toY: d.expense,
            width: 14,
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFFEC4899),
          ),
        ],
      );
    });
  }

  FlTitlesData _titles(List<_ChartUnit> data) {
    return FlTitlesData(
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              data[v.toInt()].label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  BarTouchData _tooltip() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: const Color(0xFF111827),
        getTooltipItem: (_, __, rod, rodIndex) {
          final isIncome = rodIndex == 0;
          return BarTooltipItem(
            '${isIncome ? 'Income' : 'Expense'}\n₹${rod.toY.toStringAsFixed(0)}',
            TextStyle(
              color: isIncome
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFEC4899),
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }

  String _title() {
    return range == ReportRange.thisMonth
        ? 'Monthly Overview'
        : '6 Month Overview';
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

  static String _monthName(int m) =>
      const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
}

// ---------------- MODELS ----------------

class _ChartUnit {
  final String label;
  final double income;
  final double expense;

  _ChartUnit({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
