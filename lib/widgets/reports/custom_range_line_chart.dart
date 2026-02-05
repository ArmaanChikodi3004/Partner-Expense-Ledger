// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import '../../data/demo_entries.dart';

// class CustomRangeLineChart extends StatelessWidget {
//   final List<DemoEntry> entries;

//   const CustomRangeLineChart({super.key, required this.entries});

//   @override
//   Widget build(BuildContext context) {
//     if (entries.isEmpty) {
//       return _glassCard(
//         child: const Center(
//           child: Text(
//             'No data for selected range',
//             style: TextStyle(color: Colors.white70),
//           ),
//         ),
//       );
//     }

//     final Map<DateTime, Map<String, double>> grouped = {};

//     for (final e in entries) {
//       final d = DateTime(e.date.year, e.date.month, e.date.day);
//       grouped.putIfAbsent(d, () => {'income': 0, 'expense': 0});
//       grouped[d]![e.type == EntryType.income ? 'income' : 'expense'] =
//           grouped[d]![e.type == EntryType.income ? 'income' : 'expense']! +
//               e.amount;
//     }

//     final dates = grouped.keys.toList()..sort();

//     final incomeSpots = <FlSpot>[];
//     final expenseSpots = <FlSpot>[];

//     for (int i = 0; i < dates.length; i++) {
//       incomeSpots.add(
//         FlSpot(i.toDouble(), grouped[dates[i]]!['income']!),
//       );
//       expenseSpots.add(
//         FlSpot(i.toDouble(), grouped[dates[i]]!['expense']!),
//       );
//     }

//     // ✅ CRITICAL FIX: FL Chart needs at least 2 points
//     if (dates.length == 1) {
//       incomeSpots.add(
//         FlSpot(1, incomeSpots.first.y),
//       );
//       expenseSpots.add(
//         FlSpot(1, expenseSpots.first.y),
//       );
//     }

//     final maxY = [
//           ...incomeSpots.map((e) => e.y),
//           ...expenseSpots.map((e) => e.y)
//         ].reduce((a, b) => a > b ? a : b) *
//         1.2;

//     return _glassCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Income & Expense Comparison',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 16),

//           SizedBox(
//             height: 260,
//             child: LineChart(
//               LineChartData(
//                 minY: 0,
//                 maxY: maxY == 0 ? 100 : maxY,
//                 gridData: FlGridData(show: true),
//                 borderData: FlBorderData(show: false),

//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (v, _) => Text(
//                         '₹${v.toInt()}',
//                         style: const TextStyle(
//                           color: Colors.white54,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (v, _) {
//                         final index = v.toInt();
//                         if (index >= dates.length) return const SizedBox();
//                         return Padding(
//                           padding: const EdgeInsets.only(top: 6),
//                           child: Text(
//                             '${dates[index].day}/${dates[index].month}',
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 11,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   topTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false)),
//                 ),

//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: incomeSpots,
//                     isCurved: true,
//                     color: const Color(0xFF6366F1),
//                     barWidth: 3,
//                     dotData: FlDotData(show: true),
//                   ),
//                   LineChartBarData(
//                     spots: expenseSpots,
//                     isCurved: true,
//                     color: const Color(0xFFEC4899),
//                     barWidth: 3,
//                     dotData: FlDotData(show: true),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               _Legend(color: Color(0xFF6366F1), label: 'Income'),
//               SizedBox(width: 20),
//               _Legend(color: Color(0xFFEC4899), label: 'Expense'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _glassCard({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111827).withOpacity(0.6),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.white.withOpacity(0.08)),
//       ),
//       child: child,
//     );
//   }
// }

// class _Legend extends StatelessWidget {
//   final Color color;
//   final String label;

//   const _Legend({required this.color, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 6),
//         Text(label, style: const TextStyle(color: Colors.white70)),
//       ],
//     );
//   }
// }
