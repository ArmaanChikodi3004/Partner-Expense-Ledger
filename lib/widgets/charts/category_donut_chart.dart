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
                  label: _displayName(entry.key),
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
    case 'fuel':
      return const Color(0xFFF59E0B);
    case 'maintenance':
      return const Color(0xFF10B981);
    case 'lodging':
      return const Color(0xFFEC4899);
    case 'office':
      return const Color(0xFF06B6D4);
    case 'shopping':
      return const Color(0xFFEC4899);
    case 'other_expense':
      return const Color(0xFF9CA3AF);
    default:
      // deterministic color from the category id hash
      final colors = [
        const Color(0xFFA78BFA),
        const Color(0xFFFBBF24),
        const Color(0xFF34D399),
        const Color(0xFFF472B6),
        const Color(0xFF60A5FA),
        const Color(0xFFFB923C),
        const Color(0xFF2DD4BF),
      ];
      return colors[category.hashCode.abs() % colors.length];
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
    case 'rent':          return 'Rent';
    case 'food':          return 'Food';
    case 'travel':        return 'Travel';
    case 'shopping':      return 'Shopping';
    case 'other_expense': return 'Others';
    case 'fuel':          return 'Fuel';
    case 'maintenance':   return 'Maintenance';
    case 'lodging':       return 'Lodging';
    case 'office':        return 'Office';
    default:
      // If it's a custom id like 'custom_177...', just return as-is
      // If you pass the name as key this will already be 'Furniture' etc.
      return category
          .replaceFirst(RegExp(r'^custom_\d+$'), 'Custom')
          .split('_')
          .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
          .join(' ');
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