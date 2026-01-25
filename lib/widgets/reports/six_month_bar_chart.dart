import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/demo_entries.dart';

class SixMonthBarChart extends StatelessWidget {
  const SixMonthBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // ---------- Build last 6 months data ----------
    final List<_MonthData> months = List.generate(6, (index) {
      final date = DateTime(now.year, now.month - (5 - index), 1);

      final monthEntries = demoEntries.where(
        (e) =>
            e.date.month == date.month &&
            e.date.year == date.year,
      );

      final income = monthEntries
          .where((e) => e.type == EntryType.income)
          .fold(0.0, (s, e) => s + e.amount);

      final expense = monthEntries
          .where((e) => e.type == EntryType.expense)
          .fold(0.0, (s, e) => s + e.amount);

      return _MonthData(
        label: _monthName(date.month),
        income: income,
        expense: expense,
      );
    });

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '6 Month Overview',
            style: TextStyle(
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
                alignment: BarChartAlignment.spaceAround,
                barGroups: _buildBarGroups(months),
                titlesData: _titles(months),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor:
                        const Color(0xFF111827),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = months[groupIndex];
                      final isIncome = rodIndex == 0;
                      final value =
                          isIncome ? month.income : month.expense;

                      return BarTooltipItem(
                        '${isIncome ? 'Income' : 'Expense'}\n₹${value.toStringAsFixed(0)}',
                        TextStyle(
                          color: isIncome
                              ? const Color(0xFF6366F1)
                              : const Color(0xFFEC4899),
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ---------- Legend ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(
                color: Color(0xFF6366F1),
                label: 'Income',
              ),
              SizedBox(width: 20),
              _LegendDot(
                color: Color(0xFFEC4899),
                label: 'Expense',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Helpers ----------
  List<BarChartGroupData> _buildBarGroups(
      List<_MonthData> months) {
    return List.generate(months.length, (i) {
      final m = months[i];

      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: m.income,
            color: const Color(0xFF6366F1),
            width: 12,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          BarChartRodData(
            toY: m.expense,
            color: const Color(0xFFEC4899),
            width: 12,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
        ],
      );
    });
  }

  FlTitlesData _titles(List<_MonthData> months) {
    return FlTitlesData(
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                months[value.toInt()].label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
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

  static String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}

// ---------- Models ----------
class _MonthData {
  final String label;
  final double income;
  final double expense;

  _MonthData({
    required this.label,
    required this.income,
    required this.expense,
  });
}

// ---------- Legend ----------
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
