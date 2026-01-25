import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),

          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,

          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 90),
                FlSpot(1, 40),
                FlSpot(2, 30),
                FlSpot(3, 30),
                FlSpot(4, 30),
                FlSpot(5, 30),
                FlSpot(6, 30),
              ],
              isCurved: true,
              curveSmoothness: 0.4,
              color: const Color(0xFF6366F1),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.35),
                    const Color(0xFF6366F1).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
