// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import '../../data/demo_entries.dart';

// class SixMonthBarChart extends StatefulWidget {
//   final List<DemoEntry> entries;

//   const SixMonthBarChart({
//     super.key,
//     required this.entries,
//   });

//   @override
//   State<SixMonthBarChart> createState() => _SixMonthBarChartState();
// }

// class _SixMonthBarChartState extends State<SixMonthBarChart> {
//   late int selectedYear;

//   @override
//   void initState() {
//     super.initState();
//     selectedYear = DateTime.now().year;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = _buildYearData(selectedYear);

//     return _glassCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 🔹 Header + Year Picker
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Year Overview",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//               DropdownButton<int>(
//                 value: selectedYear,
//                 dropdownColor: const Color(0xFF111827),
//                 style: const TextStyle(color: Colors.white),
//                 underline: const SizedBox(),
//                 onChanged: (year) {
//                   if (year == null) return;
//                   setState(() => selectedYear = year);
//                 },
//                 items: List.generate(5, (i) {
//                   final year = DateTime.now().year - i;
//                   return DropdownMenuItem(
//                     value: year,
//                     child: Text("$year"),
//                   );
//                 }),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // 🔹 Horizontal Scroll Chart
//           SizedBox(
//             height: 260,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SizedBox(
//                 width: 900,
//                 child: BarChart(
//                   BarChartData(
//                     minY: 0,
//                     barGroups: _barGroups(data),
//                     titlesData: _titles(data),
//                     gridData: FlGridData(show: false),
//                     borderData: FlBorderData(show: false),
//                     barTouchData: _tooltip(),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _LegendDot(color: Color(0xFF6366F1), label: 'Income'),
//               SizedBox(width: 20),
//               _LegendDot(color: Color(0xFFEC4899), label: 'Expense'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------- DATA ----------------

//   List<_ChartUnit> _buildYearData(int year) {
//     return List.generate(12, (i) {
//       final month = i + 1;

//       final monthEntries = widget.entries.where(
//         (e) => e.date.year == year && e.date.month == month,
//       );

//       final income = monthEntries
//           .where((e) => e.type == EntryType.income)
//           .fold(0.0, (s, e) => s + e.amount);

//       final expense = monthEntries
//           .where((e) => e.type == EntryType.expense)
//           .fold(0.0, (s, e) => s + e.amount);

//       return _ChartUnit(
//         label: _monthName(month),
//         income: income,
//         expense: expense,
//       );
//     });
//   }

//   // ---------------- BAR GROUPS ----------------

//   List<BarChartGroupData> _barGroups(List<_ChartUnit> data) {
//     return List.generate(data.length, (i) {
//       final d = data[i];

//       return BarChartGroupData(
//         x: i,
//         barsSpace: 6,
//         barRods: [
//           BarChartRodData(
//             toY: d.income,
//             width: 14,
//             borderRadius: BorderRadius.circular(6),
//             color: const Color(0xFF6366F1),
//           ),
//           BarChartRodData(
//             toY: d.expense,
//             width: 14,
//             borderRadius: BorderRadius.circular(6),
//             color: const Color(0xFFEC4899),
//           ),
//         ],
//       );
//     });
//   }

//   // ---------------- TITLES ----------------

//   FlTitlesData _titles(List<_ChartUnit> data) {
//     return FlTitlesData(
//       leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           getTitlesWidget: (value, _) {
//             return Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(
//                 data[value.toInt()].label,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ---------------- TOOLTIP ----------------

//   BarTouchData _tooltip() {
//     return BarTouchData(
//       enabled: true,
//       touchTooltipData: BarTouchTooltipData(
//         tooltipBgColor: const Color(0xFF111827),
//         getTooltipItem: (_, __, rod, rodIndex) {
//           final isIncome = rodIndex == 0;

//           return BarTooltipItem(
//             '${isIncome ? 'Income' : 'Expense'}\n₹${rod.toY.toStringAsFixed(0)}',
//             TextStyle(
//               color: isIncome
//                   ? const Color(0xFF6366F1)
//                   : const Color(0xFFEC4899),
//               fontWeight: FontWeight.w600,
//             ),
//           );
//         },
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

//   static String _monthName(int m) =>
//       const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
// }

// // ---------------- MODELS ----------------

// class _ChartUnit {
//   final String label;
//   final double income;
//   final double expense;

//   _ChartUnit({
//     required this.label,
//     required this.income,
//     required this.expense,
//   });
// }

// class _LegendDot extends StatelessWidget {
//   final Color color;
//   final String label;

//   const _LegendDot({
//     required this.color,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration:
//               BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style:
//               const TextStyle(color: Colors.white70, fontSize: 12),
//         ),
//       ],
//     );
//   }
// }





import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/demo_entries.dart';

class SixMonthBarChart extends StatefulWidget {
  final List<DemoEntry> entries;

  const SixMonthBarChart({
    super.key,
    required this.entries,
  });

  @override
  State<SixMonthBarChart> createState() => _SixMonthBarChartState();
}

class _SixMonthBarChartState extends State<SixMonthBarChart> {
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year;
  }

  // 🔥 IMPORTANT FIX — ensures chart updates when new entries come
  @override
  void didUpdateWidget(covariant SixMonthBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.entries != widget.entries) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _buildYearData(selectedYear);

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Year Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              DropdownButton<int>(
                value: selectedYear,
                dropdownColor: const Color(0xFF111827),
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                onChanged: (year) {
                  if (year == null) return;
                  setState(() => selectedYear = year);
                },
                items: List.generate(5, (i) {
                  final year = DateTime.now().year - i;
                  return DropdownMenuItem(
                    value: year,
                    child: Text("$year"),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 260,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: data.length * 70,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    barGroups: _barGroups(data),
                    titlesData: _titles(data),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: _tooltip(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

  List<_ChartUnit> _buildYearData(int year) {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    final monthCount = year == currentYear ? currentMonth : 12;

    return List.generate(monthCount, (i) {
      final month = i + 1;

      final monthEntries = widget.entries.where(
        (e) => e.date.year == year && e.date.month == month,
      );

      final income = monthEntries
          .where((e) => e.type == EntryType.income)
          .fold(0.0, (s, e) => s + e.amount);

      final expense = monthEntries
          .where((e) => e.type == EntryType.expense)
          .fold(0.0, (s, e) => s + e.amount);

      return _ChartUnit(
        label: _monthName(month),
        income: income,
        expense: expense,
      );
    });
  }

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
          getTitlesWidget: (value, _) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                data[value.toInt()].label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            );
          },
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
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style:
              const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
