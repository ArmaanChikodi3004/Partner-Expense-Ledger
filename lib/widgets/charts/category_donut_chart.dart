import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryDonutChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryDonutChart({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Text(
        'No expense data',
        style: TextStyle(color: Colors.white60),
      );
    }

    final total =
        categoryTotals.values.fold(0.0, (a, b) => a + b);

    final entries = categoryTotals.entries.toList();

    return Row(
      children: [
        // ---------------- DONUT ----------------
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 45,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              sections: entries.map((entry) {
                final percent =
                    (entry.value / total) * 100;

                return PieChartSectionData(
                  value: entry.value,
                  color: _colorForCategory(entry.key),
                  radius: 18,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // ---------------- LEGEND ----------------
        Expanded(
          child: Column(
            children: entries.map((entry) {
              final percent =
                  (entry.value / total) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _LegendItem(
                  color: _colorForCategory(entry.key),
             label: '${_emojiForCategory(entry.key)} ${_displayName(entry.key)}',

                  value: '${percent.toStringAsFixed(1)}%',
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ---------------- HELPERS ----------------
  Color _colorForCategory(String category) {
    switch (category) {
      case 'rent':
        return const Color(0xFF8B5CF6);
      case 'food':
        return const Color(0xFFEF4444);
      case 'travel':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }

  String _emojiForCategory(String category) {
    switch (category) {
      case 'rent':
        return '🏠';
      case 'food':
        return '🍔';
      case 'travel':
        return '✈️';
      default:
        return '🧾';
    }
  }
}

String _displayName(String category) {
  switch (category) {
    case 'rent':
      return 'Rent';
    case 'food':
      return 'Food';
    case 'travel':
      return 'Travel';
    case 'shopping':
      return 'Shopping';
    case 'other_expense':
      return 'Others';
    default:
      return category;
  }
}


class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
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
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
