import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
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
              sections: _sections(),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // ---------------- LEGEND ----------------
        Expanded(
          child: Column(
            children: const [
              _LegendItem(
                color: Color(0xFF8B5CF6),
                label: '🏠 Rent',
                value: '69%',
              ),
              SizedBox(height: 14),
              _LegendItem(
                color: Color(0xFFEF4444),
                label: '🍔 Food',
                value: '7%',
              ),
              SizedBox(height: 14),
              _LegendItem(
                color: Color(0xFF3B82F6),
                label: '✈️ Travel',
                value: '24%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _sections() {
    return [
      PieChartSectionData(
        value: 69,
        color: const Color(0xFF8B5CF6),
        radius: 18,
        showTitle: false,
      ),
      PieChartSectionData(
        value: 7,
        color: const Color(0xFFEF4444),
        radius: 18,
        showTitle: false,
      ),
      PieChartSectionData(
        value: 24,
        color: const Color(0xFF3B82F6),
        radius: 18,
        showTitle: false,
      ),
    ];
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
