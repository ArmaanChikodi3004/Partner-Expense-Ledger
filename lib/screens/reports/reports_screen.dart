// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../data/demo_entries.dart';
// import '../../data/demo_categories.dart' hide EntryType;
// import '../../widgets/reports/six_month_bar_chart.dart';
// import '../../models/report_range.dart';
// import '../../services/expense_service.dart';
// import '../../constants/active_partner.dart';

// enum DateChip { today, thisMonth, lastMonth, custom }
// enum ChartMode { sixMonths }
// enum CustomChartRange { today, twoDays, sevenDays, fifteenDays, month, custom }

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   // -------- SUMMARY FILTER
//   DateTimeRange? selectedRange;
//   DateChip activeDateChip = DateChip.thisMonth;
//   int selectedYear = DateTime.now().year;


//   // -------- CHART FILTER
//   ChartMode chartMode = ChartMode.sixMonths;
//   CustomChartRange activeCustomChartRange = CustomChartRange.month;
//   DateTimeRange? customChartRange;

//   String formatCurrency(double v) => '₹${v.toStringAsFixed(0)}';

//   // ---------------- SUMMARY RANGE ----------------
//   DateTimeRange _rangeForChip(DateChip chip) {
//     final now = DateTime.now();
//     switch (chip) {
//       case DateChip.today:
//         return DateTimeRange(
//           start: DateTime(now.year, now.month, now.day),
//           end: DateTime(now.year, now.month, now.day, 23, 59, 59),
//         );
//       case DateChip.lastMonth:
//         return DateTimeRange(
//           start: DateTime(now.year, now.month - 1, 1),
//           end: DateTime(now.year, now.month, 0),
//         );
//       default:
//         return DateTimeRange(
//           start: DateTime(now.year, now.month, 1),
//           end: DateTime(now.year, now.month + 1, 0),
//         );
//     }
//   }

//   // ---------------- CHART RANGE ----------------
//   DateTimeRange _rangeForCustomChart(CustomChartRange r) {
//     final now = DateTime.now();
//     switch (r) {
//       case CustomChartRange.today:
//         return DateTimeRange(
//           start: DateTime(now.year, now.month, now.day),
//           end: now,
//         );
//       case CustomChartRange.twoDays:
//         return DateTimeRange(
//           start: now.subtract(const Duration(days: 2)),
//           end: now,
//         );
//       case CustomChartRange.sevenDays:
//         return DateTimeRange(
//           start: now.subtract(const Duration(days: 7)),
//           end: now,
//         );
//       case CustomChartRange.fifteenDays:
//         return DateTimeRange(
//           start: now.subtract(const Duration(days: 15)),
//           end: now,
//         );
//       case CustomChartRange.month:
//         return DateTimeRange(
//           start: DateTime(now.year, now.month, 1),
//           end: DateTime(now.year, now.month + 1, 0),
//         );
//       case CustomChartRange.custom:
//         return customChartRange!;
//     }
//   }

//   // ---------------- FIRESTORE ----------------
//   List<DemoEntry> _fromFirestore(
//     List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
//   ) {
//     return docs.map((doc) {
//       final data = doc.data();
//       final ts = data['createdAt'] as Timestamp?;
//       return DemoEntry(
//         id: doc.id,
//         amount: (data['amount'] as num).toDouble(),
//         type: data['type'] == 'income'
//             ? EntryType.income
//             : EntryType.expense,
//         category: data['category'],
//         categoryIcon: '💸',
//         color: data['type'] == 'income'
//             ? const Color(0xFF6366F1)
//             : const Color(0xFFEC4899),
//         addedBy: data['paidBy'],
//         date: ts?.toDate() ?? DateTime.now(),
//       );
//     }).toList();
//   }

//   double _sum(List<DemoEntry> list, EntryType type) =>
//       list.where((e) => e.type == type).fold(0.0, (s, e) => s + e.amount);

//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: ExpenseService.getExpenses(partnerId: activePartnerId),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();

//         final docs = snapshot.data!.docs;

//         final DateTimeRange summaryRange =
//     activeDateChip == DateChip.custom && selectedRange != null
//         ? DateTimeRange(
//             start: DateTime(
//               selectedRange!.start.year,
//               selectedRange!.start.month,
//               selectedRange!.start.day,
//             ),
//             end: DateTime(
//               selectedRange!.end.year,
//               selectedRange!.end.month,
//               selectedRange!.end.day,
//               23,
//               59,
//               59,
//             ),
//           )
//         : _rangeForChip(activeDateChip);

//         final DateTimeRange chartRange =
//     activeCustomChartRange == CustomChartRange.custom &&
//             customChartRange != null
//         ? DateTimeRange(
//             start: DateTime(
//               customChartRange!.start.year,
//               customChartRange!.start.month,
//               customChartRange!.start.day,
//             ),
//             end: DateTime(
//               customChartRange!.end.year,
//               customChartRange!.end.month,
//               customChartRange!.end.day,
//               23,
//               59,
//               59,
//             ),
//           )
//         : _rangeForCustomChart(activeCustomChartRange);


//        final summaryEntries = _fromFirestore(docs.where((d) {
//   final t = (d['createdAt'] as Timestamp?)?.toDate();
//   return t != null &&
//       !t.isBefore(summaryRange.start) &&
//       !t.isAfter(summaryRange.end);
// }).toList());

// // 🔥 FIXED
// final chartEntries = _fromFirestore(docs);


//         final income = _sum(summaryEntries, EntryType.income);
//         final expense = _sum(summaryEntries, EntryType.expense);

//         return SingleChildScrollView(
//   padding: const EdgeInsets.all(16),
//   physics: const BouncingScrollPhysics(),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text(
//         'Reports',
//         style: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),

//       const SizedBox(height: 16),

//       _dateChips(context),

//       const SizedBox(height: 16),

//       _summaryCard(
//         income,
//         expense,
//         income - expense,
//         summaryEntries.length,
//       ),

//       const SizedBox(height: 24),

//       // 🔹 TOP SPENDING MOVED UP
//       _topSpendingSection(summaryEntries),

//       const SizedBox(height: 24),

//       // 🔹 CHART CONTROLS
//       _chartChips(context),

//       const SizedBox(height: 16),

//       // 🔹 6 MONTH OVERVIEW MOVED BELOW
//       SixMonthBarChart(
//         entries: chartEntries,
       
//       ),

//       const SizedBox(height: 120),
//     ],
//   ),
// );

//       },
//     );
//   }

//   // ---------------- CHART CHIPS ----------------
//  Widget _chartChips(BuildContext context) {
//   return Wrap(
//     spacing: 10,
//     children: [
//       _darkChip(
//         label: _customChartRangeLabel(activeCustomChartRange),
//         active: false,
//         showArrow: true,
//         onTap: () async {
//           final picked = await showModalBottomSheet<CustomChartRange>(
//             context: context,
//             backgroundColor: const Color(0xFF111827),
//             builder: (_) => _customChartRangePicker(),
//           );
//           if (picked == null) return;

//           if (picked == CustomChartRange.custom) {
//             final range = await showDateRangePicker(
//               context: context,
//               firstDate: DateTime(2020),
//               lastDate: DateTime.now(),
//               initialEntryMode: DatePickerEntryMode.calendarOnly,
//               builder: (_, child) => Theme(
//                 data: ThemeData.dark().copyWith(
//                   colorScheme: const ColorScheme.dark(
//                     primary: Color(0xFF6366F1),
//                   ),
//                 ),
//                 child: child!,
//               ),
//             );
//             if (range == null) return;
//             customChartRange = range;
//           }

//           setState(() => activeCustomChartRange = picked);
//         },
//       ),
//     ],
//   );
// }


//   Widget _customChartRangePicker() {
//     return ListView(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       children: CustomChartRange.values.map((r) {
//         return ListTile(
//           title: Text(
//             _customChartRangeLabel(r),
//             style: const TextStyle(color: Colors.white),
//           ),
//           onTap: () => Navigator.pop(context, r),
//         );
//       }).toList(),
//     );
//   }

//   String _customChartRangeLabel(CustomChartRange r) {
//     switch (r) {
//       case CustomChartRange.today:
//         return 'Today';
//       case CustomChartRange.twoDays:
//         return '2 Days';
//       case CustomChartRange.sevenDays:
//         return '7 Days';
//       case CustomChartRange.fifteenDays:
//         return '15 Days';
//       case CustomChartRange.month:
//         return 'Month';
//       case CustomChartRange.custom:
//         return 'Custom';
//     }
//   }

//   // ---------------- COMMON UI ----------------
//   Widget _darkChip({
//     required String label,
//     required bool active,
//     required VoidCallback onTap,
//     bool showArrow = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: active
//               ? const Color(0xFF6366F1)
//               : const Color(0xFF1F2937),
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: active ? Colors.white : Colors.white70,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//             if (showArrow) ...[
//               const SizedBox(width: 6),
//               const Icon(
//                 Icons.keyboard_arrow_down,
//                 size: 18,
//                 color: Colors.white70,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------- DATE CHIPS ----------------
//   Widget _dateChips(BuildContext context) {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: DateChip.values.map((c) {
//         return _darkChip(
//           label: _dateLabel(c),
//           active: activeDateChip == c,
//           onTap: () async {
//             if (c == DateChip.custom) {
//               final picked = await showDateRangePicker(
//                 context: context,
//                 firstDate: DateTime(2020),
//                 lastDate: DateTime.now(),
//                 builder: (_, child) =>
//                     Theme(data: ThemeData.dark(), child: child!),
//               );
//               if (picked == null) return;
//               setState(() {
//                 activeDateChip = c;
//                 selectedRange = picked;
//               });
//             } else {
//               setState(() {
//                 activeDateChip = c;
//                 selectedRange = null;
//               });
//             }
//           },
//         );
//       }).toList(),
//     );
//   }

//   String _dateLabel(DateChip c) {
//     switch (c) {
//       case DateChip.today:
//         return 'Today';
//       case DateChip.thisMonth:
//         return 'This Month';
//       case DateChip.lastMonth:
//         return 'Last Month';
//       case DateChip.custom:
//         return 'Custom';
//     }
//   }

//   // ---------------- SUMMARY UI ----------------
//   Widget _summaryCard(
//     double income,
//     double expense,
//     double balance,
//     int count,
//   ) {
//     return _glassCard(
//       GridView.count(
//         crossAxisCount: 2,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         children: [
//           _stat('Income', formatCurrency(income), const Color(0xFF6366F1)),
//           _stat('Expenses', formatCurrency(expense), const Color(0xFFEC4899)),
//           _stat(
//             'Net Balance',
//             formatCurrency(balance),
//             balance >= 0
//                 ? const Color(0xFF22C55E)
//                 : const Color(0xFFEF4444),
//           ),
//           _stat('Transactions', '$count', Colors.white),
//         ],
//       ),
//     );
//   }

//   Widget _stat(String label, String value, Color color) {
//     const emojis = {
//       'Income': '📈',
//       'Expenses': '📉',
//       'Net Balance': '📊',
//       'Transactions': '🧾',
//     };

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.white70)),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Spacer(),
//           Align(
//             alignment: Alignment.bottomRight,
//             child: Text(
//               emojis[label] ?? '',
//               style: const TextStyle(fontSize: 26),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  Widget _topSpendingSection(List<DemoEntry> entries) {
//   final expenses =
//       entries.where((e) => e.type == EntryType.expense).toList();
//   if (expenses.isEmpty) return const SizedBox();

//   final totals = <String, double>{};

//   for (final e in expenses) {
//     totals[e.category] = (totals[e.category] ?? 0) + e.amount;
//   }

//   final sorted = totals.entries.toList()
//     ..sort((a, b) => b.value.compareTo(a.value));

//   final max = sorted.first.value;

//   return _glassCard(
//     Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Top Spending Categories',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 16),

//         ...sorted.take(5).map((e) {
//           // 🔥 Convert category ID to proper name
//           final category = demoCategories.firstWhere(
//             (c) => c.id == e.key,
//             orElse: () => demoCategories.first,
//           );

//           return Padding(
//             padding: const EdgeInsets.only(bottom: 14),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       category.name, // ✅ SHOWS "Food" instead of "food"
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     Text(
//                       formatCurrency(e.value),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: LinearProgressIndicator(
//                     value: e.value / max,
//                     minHeight: 8,
//                     backgroundColor: Colors.white12,
//                     valueColor: const AlwaysStoppedAnimation(
//                       Color(0xFFEC4899),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     ),
//   );
// }


//   Widget _glassCard(Widget child) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111827).withOpacity(0.6),
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: child,
//     );
//   }
// }

//claude 

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/demo_entries.dart';
import '../../data/demo_categories.dart' hide EntryType;
import '../../widgets/reports/six_month_bar_chart.dart';
import '../../models/report_range.dart';
import '../../services/expense_service.dart';
import '../../services/pdf_service.dart';
import '../../constants/active_partner.dart';

enum DateChip { today, thisMonth, lastMonth, custom }
enum ChartMode { sixMonths }
enum CustomChartRange { today, twoDays, sevenDays, fifteenDays, month, custom }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // -------- SUMMARY FILTER
  DateTimeRange? selectedRange;
  DateChip activeDateChip = DateChip.thisMonth;
  int selectedYear = DateTime.now().year;

  // -------- CHART FILTER
  ChartMode chartMode = ChartMode.sixMonths;
  CustomChartRange activeCustomChartRange = CustomChartRange.month;
  DateTimeRange? customChartRange;

  // -------- PDF STATE
  bool _isGeneratingPdf = false;

  String formatCurrency(double v) => '₹${v.toStringAsFixed(0)}';

  // ---------------- SUMMARY RANGE ----------------
  DateTimeRange _rangeForChip(DateChip chip) {
    final now = DateTime.now();
    switch (chip) {
      case DateChip.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
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

  // ---------------- CHART RANGE ----------------
  DateTimeRange _rangeForCustomChart(CustomChartRange r) {
    final now = DateTime.now();
    switch (r) {
      case CustomChartRange.today:
        return DateTimeRange(start: DateTime(now.year, now.month, now.day), end: now);
      case CustomChartRange.twoDays:
        return DateTimeRange(start: now.subtract(const Duration(days: 2)), end: now);
      case CustomChartRange.sevenDays:
        return DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
      case CustomChartRange.fifteenDays:
        return DateTimeRange(start: now.subtract(const Duration(days: 15)), end: now);
      case CustomChartRange.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case CustomChartRange.custom:
        return customChartRange!;
    }
  }

  // ---------------- FIRESTORE ----------------
  List<DemoEntry> _fromFirestore(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map((doc) {
      final data = doc.data();
      final ts = data['createdAt'] as Timestamp?;
      return DemoEntry(
        id: doc.id,
        amount: (data['amount'] as num).toDouble(),
        type: data['type'] == 'income' ? EntryType.income : EntryType.expense,
        category: data['category'],
        categoryIcon: '💸',
        color: data['type'] == 'income'
            ? const Color(0xFF6366F1)
            : const Color(0xFFEC4899),
        addedBy: data['paidBy'],
        date: ts?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  double _sum(List<DemoEntry> list, EntryType type) =>
      list.where((e) => e.type == type).fold(0.0, (s, e) => s + e.amount);

  // ---------------- PDF ACTIONS ----------------
  Future<void> _downloadPdf(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTimeRange summaryRange,
  ) async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfService.downloadReport(
        expenses: docs,
        range: summaryRange,
        partnerName: 'Swastik Hangers',
        context: context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: const Color(0xFF374151),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _previewPdf(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTimeRange summaryRange,
  ) async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfService.previewReport(
        expenses: docs,
        range: summaryRange,
        partnerName: 'Swastik Hangers',
        context: context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to preview PDF: $e'),
            backgroundColor: const Color(0xFF374151),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ExpenseService.getExpenses(partnerId: activePartnerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final docs = snapshot.data!.docs;

        final DateTimeRange summaryRange =
            activeDateChip == DateChip.custom && selectedRange != null
                ? DateTimeRange(
                    start: DateTime(selectedRange!.start.year,
                        selectedRange!.start.month, selectedRange!.start.day),
                    end: DateTime(selectedRange!.end.year,
                        selectedRange!.end.month, selectedRange!.end.day, 23, 59, 59),
                  )
                : _rangeForChip(activeDateChip);

        final DateTimeRange chartRange =
            activeCustomChartRange == CustomChartRange.custom &&
                    customChartRange != null
                ? DateTimeRange(
                    start: DateTime(customChartRange!.start.year,
                        customChartRange!.start.month, customChartRange!.start.day),
                    end: DateTime(customChartRange!.end.year,
                        customChartRange!.end.month, customChartRange!.end.day, 23, 59, 59),
                  )
                : _rangeForCustomChart(activeCustomChartRange);

        final summaryEntries = _fromFirestore(docs.where((d) {
          final t = (d['createdAt'] as Timestamp?)?.toDate();
          return t != null &&
              !t.isBefore(summaryRange.start) &&
              !t.isAfter(summaryRange.end);
        }).toList());

        final chartEntries = _fromFirestore(docs);

        final income = _sum(summaryEntries, EntryType.income);
        final expense = _sum(summaryEntries, EntryType.expense);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ROW ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // ── PDF BUTTONS ──
                  Row(
                    children: [
                      _pdfButton(
                        icon: Icons.visibility_outlined,
                        label: 'Preview',
                        onTap: _isGeneratingPdf
                            ? null
                            : () => _previewPdf(docs, summaryRange),
                      ),
                      const SizedBox(width: 8),
                      _pdfButton(
                        icon: Icons.download_outlined,
                        label: 'Download',
                        onTap: _isGeneratingPdf
                            ? null
                            : () => _downloadPdf(docs, summaryRange),
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),

              // ── GENERATING INDICATOR ──
              if (_isGeneratingPdf) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Generating PDF...',
                        style: TextStyle(color: Color(0xFF6366F1), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              _dateChips(context),
              const SizedBox(height: 16),
              _summaryCard(income, expense, income - expense, summaryEntries.length),
              const SizedBox(height: 24),
              _topSpendingSection(summaryEntries),
              const SizedBox(height: 24),
              _chartChips(context),
              const SizedBox(height: 16),
              SixMonthBarChart(entries: chartEntries),
              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  // ── PDF BUTTON ──
  Widget _pdfButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary
                ? const Color(0xFF6366F1)
                : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CHART CHIPS ----------------
  Widget _chartChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        _darkChip(
          label: _customChartRangeLabel(activeCustomChartRange),
          active: false,
          showArrow: true,
          onTap: () async {
            final picked = await showModalBottomSheet<CustomChartRange>(
              context: context,
              backgroundColor: const Color(0xFF111827),
              builder: (_) => _customChartRangePicker(),
            );
            if (picked == null) return;

            if (picked == CustomChartRange.custom) {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                builder: (_, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(primary: Color(0xFF6366F1)),
                  ),
                  child: child!,
                ),
              );
              if (range == null) return;
              customChartRange = range;
            }

            setState(() => activeCustomChartRange = picked);
          },
        ),
      ],
    );
  }

  Widget _customChartRangePicker() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: CustomChartRange.values.map((r) {
        return ListTile(
          title: Text(
            _customChartRangeLabel(r),
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () => Navigator.pop(context, r),
        );
      }).toList(),
    );
  }

  String _customChartRangeLabel(CustomChartRange r) {
    switch (r) {
      case CustomChartRange.today:      return 'Today';
      case CustomChartRange.twoDays:    return '2 Days';
      case CustomChartRange.sevenDays:  return '7 Days';
      case CustomChartRange.fifteenDays: return '15 Days';
      case CustomChartRange.month:      return 'Month';
      case CustomChartRange.custom:     return 'Custom';
    }
  }

  Widget _darkChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6366F1) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.white70),
            ],
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
                builder: (_, child) => Theme(data: ThemeData.dark(), child: child!),
              );
              if (picked == null) return;
              setState(() {
                activeDateChip = c;
                selectedRange = picked;
              });
            } else {
              setState(() {
                activeDateChip = c;
                selectedRange = null;
              });
            }
          },
        );
      }).toList(),
    );
  }

  String _dateLabel(DateChip c) {
    switch (c) {
      case DateChip.today:     return 'Today';
      case DateChip.thisMonth: return 'This Month';
      case DateChip.lastMonth: return 'Last Month';
      case DateChip.custom:    return 'Custom';
    }
  }

  // ---------------- SUMMARY UI ----------------
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
          _stat('Net Balance', formatCurrency(balance),
              balance >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
          _stat('Transactions', '$count', Colors.white),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    const emojis = {
      'Income': '📈',
      'Expenses': '📉',
      'Net Balance': '📊',
      'Transactions': '🧾',
    };

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
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(emojis[label] ?? '', style: const TextStyle(fontSize: 26)),
          ),
        ],
      ),
    );
  }

  Widget _topSpendingSection(List<DemoEntry> entries) {
    final expenses = entries.where((e) => e.type == EntryType.expense).toList();
    if (expenses.isEmpty) return const SizedBox();

    final totals = <String, double>{};
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
            final category = demoCategories.firstWhere(
              (c) => c.id == e.key,
              orElse: () => demoCategories.first,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category.name, style: const TextStyle(color: Colors.white)),
                      Text(
                        formatCurrency(e.value),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: e.value / max,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFEC4899)),
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
      ),
      child: child,
    );
  }
}
