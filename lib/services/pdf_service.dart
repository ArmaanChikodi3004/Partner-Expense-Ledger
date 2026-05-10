// // import 'package:flutter/material.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;
// // import 'package:printing/printing.dart';
// // import 'package:intl/intl.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:printing/printing.dart';
// // import 'dart:typed_data';

// // class PdfService {
// //   // Use "Rs." instead of "₹" — default PDF font has no Unicode support
// //   static String _formatCurrency(double amount) =>
// //       'Rs. ${amount.toStringAsFixed(0)}';

// //   static String _formatDate(DateTime date) =>
// //       DateFormat('dd MMM yyyy').format(date);

// //   static String _categoryDisplayName(String id) {
// //     const names = {
// //       'food': 'Food',
// //       'travel': 'Travel',
// //       'shopping': 'Shopping',
// //       'fuel': 'Fuel',
// //       'maintenance': 'Maintenance',
// //       'lodging': 'Lodging',
// //       'office': 'Office',
// //       'other_expense': 'Others',
// //       'salary': 'Salary',
// //       'freelance': 'Freelance',
// //       'other_income': 'Others',
// //     };
// //     return names[id] ?? id;
// //   }

// //   // ─────────────────────────────────────────────
// //   // GENERATE PDF BYTES
// //   // ─────────────────────────────────────────────
// //   static Future<Uint8List> generateReport({
// //     required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
// //     required DateTimeRange range,
// //     required String partnerName,
// //   }) async {
// //     final pdf = pw.Document();

// //     // Filter to range
// //     final filtered = expenses.where((doc) {
// //       final data = doc.data();
// //       final ts = data['createdAt'] as Timestamp?;
// //       if (ts == null) return false;
// //       final date = ts.toDate();
// //       return !date.isBefore(range.start) && !date.isAfter(range.end);
// //     }).toList();

// //     // Totals
// //     double totalIncome = 0;
// //     double totalExpense = 0;
// //     final Map<String, double> categoryTotals = {};

// //     for (final doc in filtered) {
// //       final data = doc.data();
// //       final amount = (data['amount'] as num).toDouble();
// //       final type = data['type'] as String;
// //       final category = data['category'] as String;
// //       final title = (data['title'] as String?) ?? '';

// //       if (type == 'income') {
// //         totalIncome += amount;
// //       } else {
// //         totalExpense += amount;
// //         final key = category.startsWith('custom_')
// //             ? (title.isNotEmpty ? title : category)
// //             : _categoryDisplayName(category);
// //         categoryTotals[key] = (categoryTotals[key] ?? 0) + amount;
// //       }
// //     }

// //     final balance = totalIncome - totalExpense;

// //     final sortedCategories = categoryTotals.entries.toList()
// //       ..sort((a, b) => b.value.compareTo(a.value));

// //     // PDF Colors
// //     const primaryColor = PdfColor.fromInt(0xFF6366F1);
// //     const incomeColor = PdfColor.fromInt(0xFF22C55E);
// //     const expenseColor = PdfColor.fromInt(0xFFEF4444);
// //     const bgColor = PdfColor.fromInt(0xFF111827);
// //     const cardColor = PdfColor.fromInt(0xFF1F2937);
// //     const textColor = PdfColor.fromInt(0xFFFFFFFF);
// //     const subtextColor = PdfColor.fromInt(0xFF9CA3AF);

// //     pdf.addPage(
// //       pw.MultiPage(
// //         pageFormat: PdfPageFormat.a4,
// //         margin: const pw.EdgeInsets.all(32),
// //         maxPages: 999,
// //         build: (pw.Context context) => [
// //           // ── HEADER ──
// //           pw.Container(
// //             padding: const pw.EdgeInsets.all(20),
// //             decoration: pw.BoxDecoration(
// //               color: bgColor,
// //               borderRadius: pw.BorderRadius.circular(16),
// //             ),
// //             child: pw.Column(
// //               crossAxisAlignment: pw.CrossAxisAlignment.start,
// //               children: [
// //                 pw.Row(
// //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     pw.Column(
// //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                       children: [
// //                         pw.Text(
// //                           'Swastik Hangers',
// //                           style: pw.TextStyle(
// //                             color: textColor,
// //                             fontSize: 22,
// //                             fontWeight: pw.FontWeight.bold,
// //                           ),
// //                         ),
// //                         pw.SizedBox(height: 4),
// //                         pw.Text(
// //                           'Expense Report',
// //                           style: pw.TextStyle(color: subtextColor, fontSize: 13),
// //                         ),
// //                       ],
// //                     ),
// //                     pw.Container(
// //                       padding: const pw.EdgeInsets.symmetric(
// //                           horizontal: 12, vertical: 6),
// //                       decoration: pw.BoxDecoration(
// //                         color: primaryColor,
// //                         borderRadius: pw.BorderRadius.circular(8),
// //                       ),
// //                       child: pw.Text(
// //                         '${_formatDate(range.start)} - ${_formatDate(range.end)}',
// //                         style: pw.TextStyle(color: textColor, fontSize: 11),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 pw.SizedBox(height: 8),
// //                 pw.Text(
// //                   'Generated on ${_formatDate(DateTime.now())}',
// //                   style: pw.TextStyle(color: subtextColor, fontSize: 11),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           pw.SizedBox(height: 20),

// //           // ── SUMMARY CARDS ──
// //           pw.Row(
// //             children: [
// //               _summaryCard('Total Income', _formatCurrency(totalIncome),
// //                   incomeColor, cardColor, textColor, subtextColor),
// //               pw.SizedBox(width: 12),
// //               _summaryCard('Total Expenses', _formatCurrency(totalExpense),
// //                   expenseColor, cardColor, textColor, subtextColor),
// //               pw.SizedBox(width: 12),
// //               _summaryCard(
// //                 'Net Balance',
// //                 _formatCurrency(balance),
// //                 balance >= 0 ? incomeColor : expenseColor,
// //                 cardColor,
// //                 textColor,
// //                 subtextColor,
// //               ),
// //               pw.SizedBox(width: 12),
// //               _summaryCard('Transactions', '${filtered.length}', primaryColor,
// //                   cardColor, textColor, subtextColor),
// //             ],
// //           ),

// //           pw.SizedBox(height: 20),

// //           // ── CATEGORY BREAKDOWN ──
// //           if (sortedCategories.isNotEmpty) ...[
// //             pw.Container(
// //               padding: const pw.EdgeInsets.all(16),
// //               decoration: pw.BoxDecoration(
// //                 color: cardColor,
// //                 borderRadius: pw.BorderRadius.circular(12),
// //               ),
// //               child: pw.Column(
// //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                 children: [
// //                   pw.Text(
// //                     'Spending by Category',
// //                     style: pw.TextStyle(
// //                       color: textColor,
// //                       fontSize: 15,
// //                       fontWeight: pw.FontWeight.bold,
// //                     ),
// //                   ),
// //                   pw.SizedBox(height: 12),
// //                  // ── TRANSACTION LIST ──
// // pw.Table(
// //   columnWidths: {
// //     0: const pw.FlexColumnWidth(2),
// //     1: const pw.FlexColumnWidth(3),
// //     2: const pw.FlexColumnWidth(2),
// //     3: const pw.FlexColumnWidth(2),
// //   },
// //   children: [
// //     // Section title row
// //     pw.TableRow(
// //       decoration: pw.BoxDecoration(color: cardColor),
// //       children: [
// //         pw.Padding(
// //           padding: const pw.EdgeInsets.fromLTRB(12, 14, 12, 10),
// //           child: pw.Text(
// //             'All Transactions',
// //             style: pw.TextStyle(
// //               color: textColor,
// //               fontSize: 15,
// //               fontWeight: pw.FontWeight.bold,
// //             ),
// //           ),
// //         ),
// //         pw.SizedBox(),
// //         pw.SizedBox(),
// //         pw.SizedBox(),
// //       ],
// //     ),
// //     // Column headers row
// //     pw.TableRow(
// //       decoration: pw.BoxDecoration(
// //         color: cardColor,
// //         border: pw.Border(
// //           bottom: pw.BorderSide(color: subtextColor, width: 0.5),
// //         ),
// //       ),
// //       children: [
// //         _tableHeader('Date', subtextColor),
// //         _tableHeader('Title', subtextColor),
// //         _tableHeader('Category', subtextColor),
// //         _tableHeader('Amount', subtextColor),
// //       ],
// //     ),
// //     // Data rows
// //     ...filtered.map((doc) {
// //       final data = doc.data();
// //       final ts = data['createdAt'] as Timestamp?;
// //       final date = ts?.toDate() ?? DateTime.now();
// //       final isIncome = data['type'] == 'income';
// //       final rawTitle = data['title'] as String? ?? '';
// //       final category = data['category'] as String;
// //       final title = rawTitle.isNotEmpty
// //           ? rawTitle
// //           : _categoryDisplayName(category);
// //       final displayCategory = category.startsWith('custom_')
// //           ? (rawTitle.isNotEmpty ? rawTitle : category)
// //           : _categoryDisplayName(category);
// //       final amount = (data['amount'] as num).toDouble();

// //       return pw.TableRow(
// //         decoration: pw.BoxDecoration(color: cardColor),
// //         children: [
// //           _tableCell(DateFormat('dd MMM').format(date), subtextColor),
// //           _tableCell(title, textColor),
// //           _tableCell(displayCategory, subtextColor),
// //           _tableCell(
// //             '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
// //             isIncome ? incomeColor : expenseColor,
// //           ),
// //         ],
// //       );
// //     }),
// //   ],
// // ),
// //             pw.SizedBox(height: 20),
// //           ],

// //           // ── TRANSACTION LIST ──
// //           pw.Container(
// //             padding: const pw.EdgeInsets.all(16),
// //             decoration: pw.BoxDecoration(
// //               color: cardColor,
// //               borderRadius: pw.BorderRadius.circular(12),
// //             ),
// //             child: pw.Column(
// //               crossAxisAlignment: pw.CrossAxisAlignment.start,
// //               children: [
// //                 pw.Text(
// //                   'All Transactions',
// //                   style: pw.TextStyle(
// //                     color: textColor,
// //                     fontSize: 15,
// //                     fontWeight: pw.FontWeight.bold,
// //                   ),
// //                 ),
// //                 pw.SizedBox(height: 12),
// //                 pw.Table(
// //                   columnWidths: {
// //                     0: const pw.FlexColumnWidth(2),
// //                     1: const pw.FlexColumnWidth(3),
// //                     2: const pw.FlexColumnWidth(2),
// //                     3: const pw.FlexColumnWidth(2),
// //                   },
// //                   children: [
// //                     pw.TableRow(
// //                       decoration: pw.BoxDecoration(
// //                         border: pw.Border(
// //                           bottom:
// //                               pw.BorderSide(color: subtextColor, width: 0.5),
// //                         ),
// //                       ),
// //                       children: [
// //                         _tableHeader('Date', subtextColor),
// //                         _tableHeader('Title', subtextColor),
// //                         _tableHeader('Category', subtextColor),
// //                         _tableHeader('Amount', subtextColor),
// //                       ],
// //                     ),
// //                     ...filtered.map((doc) {
// //                       final data = doc.data();
// //                       final ts = data['createdAt'] as Timestamp?;
// //                       final date = ts?.toDate() ?? DateTime.now();
// //                       final isIncome = data['type'] == 'income';
// //                       final rawTitle = data['title'] as String? ?? '';
// //                       final category = data['category'] as String;
// //                       final title = rawTitle.isNotEmpty
// //                           ? rawTitle
// //                           : _categoryDisplayName(category);
// //                       final displayCategory = category.startsWith('custom_')
// //                           ? (rawTitle.isNotEmpty ? rawTitle : category)
// //                           : _categoryDisplayName(category);
// //                       final amount = (data['amount'] as num).toDouble();

// //                       return pw.TableRow(
// //                         children: [
// //                           _tableCell(
// //                               DateFormat('dd MMM').format(date), subtextColor),
// //                           _tableCell(title, textColor),
// //                           _tableCell(displayCategory, subtextColor),
// //                           _tableCell(
// //                             '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
// //                             isIncome ? incomeColor : expenseColor,
// //                           ),
// //                         ],
// //                       );
// //                     }),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );

// //     return Uint8List.fromList(await pdf.save());
// //   }

// //   // ─────────────────────────────────────────────
// //   // PREVIEW PDF
// //   // ─────────────────────────────────────────────
// //   static Future<void> previewReport({
// //   required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
// //   required DateTimeRange range,
// //   required String partnerName,
// //   required BuildContext context,
// // }) async {
// //   final bytes = await generateReport(
// //     expenses: expenses,
// //     range: range,
// //     partnerName: partnerName,
// //   );

// //   if (!context.mounted) return;

// //   Navigator.push(
// //     context,
// //     MaterialPageRoute(
// //       builder: (_) => _PdfPreviewScreen(bytes: bytes),
// //     ),
// //   );
// // }
// //   // ─────────────────────────────────────────────
// //   // SAVE & SHARE PDF
// //   // ─────────────────────────────────────────────
// //   static Future<void> downloadReport({
// //     required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
// //     required DateTimeRange range,
// //     required String partnerName,
// //     required BuildContext context,
// //   }) async {
// //     final bytes = await generateReport(
// //       expenses: expenses,
// //       range: range,
// //       partnerName: partnerName,
// //     );

// //     final fileName =
// //         'expense_report_${DateFormat('yyyyMMdd').format(range.start)}_${DateFormat('yyyyMMdd').format(range.end)}.pdf';

// //     await Printing.sharePdf(bytes: bytes, filename: fileName);
// //   }

// //   // ─────────────────────────────────────────────
// //   // HELPERS
// //   // ─────────────────────────────────────────────
// //   static pw.Widget _summaryCard(
// //     String label,
// //     String value,
// //     PdfColor valueColor,
// //     PdfColor bgColor,
// //     PdfColor textColor,
// //     PdfColor subtextColor,
// //   ) {
// //     return pw.Expanded(
// //       child: pw.Container(
// //         padding: const pw.EdgeInsets.all(12),
// //         decoration: pw.BoxDecoration(
// //           color: bgColor,
// //           borderRadius: pw.BorderRadius.circular(10),
// //         ),
// //         child: pw.Column(
// //           crossAxisAlignment: pw.CrossAxisAlignment.start,
// //           children: [
// //             pw.Text(label,
// //                 style: pw.TextStyle(color: subtextColor, fontSize: 10)),
// //             pw.SizedBox(height: 6),
// //             pw.Text(
// //               value,
// //               style: pw.TextStyle(
// //                 color: valueColor,
// //                 fontSize: 14,
// //                 fontWeight: pw.FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   static pw.Widget _tableHeader(String text, PdfColor color) {
// //     return pw.Padding(
// //       padding: const pw.EdgeInsets.symmetric(vertical: 6),
// //       child: pw.Text(
// //         text,
// //         style: pw.TextStyle(
// //             color: color, fontSize: 11, fontWeight: pw.FontWeight.bold),
// //       ),
// //     );
// //   }

// //   static pw.Widget _tableCell(String text, PdfColor color) {
// //     return pw.Padding(
// //       padding: const pw.EdgeInsets.symmetric(vertical: 5),
// //       child: pw.Text(text, style: pw.TextStyle(color: color, fontSize: 11)),
// //     );
// //   }
// //   class _PdfPreviewScreen extends StatelessWidget {
// //   final Uint8List bytes;
// //   const _PdfPreviewScreen({required this.bytes});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFF0B1120),
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFF0B1120),
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: const Text(
// //           'Report Preview',
// //           style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.share, color: Colors.white),
// //             onPressed: () async {
// //               await Printing.sharePdf(
// //                 bytes: bytes,
// //                 filename: 'expense_report.pdf',
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //       body: PdfPreview(
// //         build: (_) async => bytes,
// //         allowPrinting: false,
// //         allowSharing: false,
// //         canChangePageFormat: false,
// //         canChangeOrientation: false,
// //         canDebug: false,
// //         pdfFileName: 'expense_report.pdf',
// //         actions: const [],
// //       ),
// //     );
// //   }
// // }
// // }

// //claude 

// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:typed_data';

// class PdfService {
//   static String _formatCurrency(double amount) =>
//       'Rs. ${amount.toStringAsFixed(0)}';

//   static String _formatDate(DateTime date) =>
//       DateFormat('dd MMM yyyy').format(date);

//   static String _categoryDisplayName(String id) {
//     const names = {
//       'food': 'Food',
//       'travel': 'Travel',
//       'shopping': 'Shopping',
//       'fuel': 'Fuel',
//       'maintenance': 'Maintenance',
//       'lodging': 'Lodging',
//       'office': 'Office',
//       'other_expense': 'Others',
//       'salary': 'Salary',
//       'freelance': 'Freelance',
//       'other_income': 'Others',
//     };
//     return names[id] ?? id;
//   }

//   // ─────────────────────────────────────────────
//   // GENERATE PDF BYTES
//   // ─────────────────────────────────────────────
//   static Future<Uint8List> generateReport({
//     required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
//     required DateTimeRange range,
//     required String partnerName,
//   }) async {
//     final pdf = pw.Document();

//     // Filter to range
//     final filtered = expenses.where((doc) {
//       final data = doc.data();
//       final ts = data['createdAt'] as Timestamp?;
//       if (ts == null) return false;
//       final date = ts.toDate();
//       return !date.isBefore(range.start) && !date.isAfter(range.end);
//     }).toList();

//     // Totals
//     double totalIncome = 0;
//     double totalExpense = 0;
//     final Map<String, double> categoryTotals = {};

//     for (final doc in filtered) {
//       final data = doc.data();
//       final amount = (data['amount'] as num).toDouble();
//       final type = data['type'] as String;
//       final category = data['category'] as String;
//       final title = (data['title'] as String?) ?? '';

//       if (type == 'income') {
//         totalIncome += amount;
//       } else {
//         totalExpense += amount;
//         final key = category.startsWith('custom_')
//             ? (title.isNotEmpty ? title : category)
//             : _categoryDisplayName(category);
//         categoryTotals[key] = (categoryTotals[key] ?? 0) + amount;
//       }
//     }

//     final balance = totalIncome - totalExpense;

//     final sortedCategories = categoryTotals.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     // PDF Colors
//     const primaryColor = PdfColor.fromInt(0xFF6366F1);
//     const incomeColor = PdfColor.fromInt(0xFF22C55E);
//     const expenseColor = PdfColor.fromInt(0xFFEF4444);
//     const bgColor = PdfColor.fromInt(0xFF111827);
//     const cardColor = PdfColor.fromInt(0xFF1F2937);
//     const textColor = PdfColor.fromInt(0xFFFFFFFF);
//     const subtextColor = PdfColor.fromInt(0xFF9CA3AF);

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         maxPages: 999,
//         build: (pw.Context context) => [
//           // ── HEADER ──
//           pw.Container(
//             padding: const pw.EdgeInsets.all(20),
//             decoration: pw.BoxDecoration(
//               color: bgColor,
//               borderRadius: pw.BorderRadius.circular(16),
//             ),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           partnerName.isNotEmpty ? partnerName : 'Swastik Hangers',
//                           style: pw.TextStyle(
//                             color: textColor,
//                             fontSize: 22,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(height: 4),
//                         pw.Text(
//                           'Expense Report',
//                           style: pw.TextStyle(color: subtextColor, fontSize: 13),
//                         ),
//                       ],
//                     ),
//                     pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       decoration: pw.BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: pw.BorderRadius.circular(8),
//                       ),
//                       child: pw.Text(
//                         '${_formatDate(range.start)} - ${_formatDate(range.end)}',
//                         style: pw.TextStyle(color: textColor, fontSize: 11),
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Text(
//                   'Generated on ${_formatDate(DateTime.now())}',
//                   style: pw.TextStyle(color: subtextColor, fontSize: 11),
//                 ),
//               ],
//             ),
//           ),

//           pw.SizedBox(height: 20),

//           // ── SUMMARY CARDS ──
//           pw.Row(
//             children: [
//               _summaryCard('Total Income', _formatCurrency(totalIncome),
//                   incomeColor, cardColor, textColor, subtextColor),
//               pw.SizedBox(width: 12),
//               _summaryCard('Total Expenses', _formatCurrency(totalExpense),
//                   expenseColor, cardColor, textColor, subtextColor),
//               pw.SizedBox(width: 12),
//               _summaryCard(
//                 'Net Balance',
//                 _formatCurrency(balance),
//                 balance >= 0 ? incomeColor : expenseColor,
//                 cardColor,
//                 textColor,
//                 subtextColor,
//               ),
//               pw.SizedBox(width: 12),
//               _summaryCard('Transactions', '${filtered.length}',
//                   primaryColor, cardColor, textColor, subtextColor),
//             ],
//           ),

//           pw.SizedBox(height: 20),

//           // ── CATEGORY BREAKDOWN ──
//           if (sortedCategories.isNotEmpty) ...[
//             pw.Container(
//               padding: const pw.EdgeInsets.all(16),
//               decoration: pw.BoxDecoration(
//                 color: cardColor,
//                 borderRadius: pw.BorderRadius.circular(12),
//               ),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'Spending by Category',
//                     style: pw.TextStyle(
//                       color: textColor,
//                       fontSize: 15,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.SizedBox(height: 12),
//                   pw.Table(
//                     columnWidths: {
//                       0: const pw.FlexColumnWidth(3),
//                       1: const pw.FlexColumnWidth(2),
//                       2: const pw.FlexColumnWidth(2),
//                     },
//                     children: [
//                       pw.TableRow(
//                         decoration: pw.BoxDecoration(
//                           border: pw.Border(
//                             bottom: pw.BorderSide(
//                                 color: subtextColor, width: 0.5),
//                           ),
//                         ),
//                         children: [
//                           _tableHeader('Category', subtextColor),
//                           _tableHeader('Amount', subtextColor),
//                           _tableHeader('% of Total', subtextColor),
//                         ],
//                       ),
//                       ...sortedCategories.map((e) {
//                         final pct = totalExpense > 0
//                             ? (e.value / totalExpense * 100)
//                                 .toStringAsFixed(1)
//                             : '0.0';
//                         return pw.TableRow(
//                           children: [
//                             _tableCell(e.key, textColor),
//                             _tableCell(_formatCurrency(e.value), expenseColor),
//                             _tableCell('$pct%', subtextColor),
//                           ],
//                         );
//                       }),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             pw.SizedBox(height: 20),
//           ],

//           // ── TRANSACTION LIST ──
//           pw.Table(
//             columnWidths: {
//               0: const pw.FlexColumnWidth(2),
//               1: const pw.FlexColumnWidth(3),
//               2: const pw.FlexColumnWidth(2),
//               3: const pw.FlexColumnWidth(2),
//             },
//             children: [
//               // Section title row
//               pw.TableRow(
//                 decoration: pw.BoxDecoration(color: cardColor),
//                 children: [
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.fromLTRB(12, 14, 12, 10),
//                     child: pw.Text(
//                       'All Transactions',
//                       style: pw.TextStyle(
//                         color: textColor,
//                         fontSize: 15,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   pw.SizedBox(),
//                   pw.SizedBox(),
//                   pw.SizedBox(),
//                 ],
//               ),
//               // Column headers row
//               pw.TableRow(
//                 decoration: pw.BoxDecoration(
//                   color: cardColor,
//                   border: pw.Border(
//                     bottom: pw.BorderSide(color: subtextColor, width: 0.5),
//                   ),
//                 ),
//                 children: [
//                   _tableHeader('Date', subtextColor),
//                   _tableHeader('Title', subtextColor),
//                   _tableHeader('Category', subtextColor),
//                   _tableHeader('Amount', subtextColor),
//                 ],
//               ),
//               // Data rows
//               ...filtered.map((doc) {
//                 final data = doc.data();
//                 final ts = data['createdAt'] as Timestamp?;
//                 final date = ts?.toDate() ?? DateTime.now();
//                 final isIncome = data['type'] == 'income';
//                 final rawTitle = data['title'] as String? ?? '';
//                 final category = data['category'] as String;
//                 final title = rawTitle.isNotEmpty
//                     ? rawTitle
//                     : _categoryDisplayName(category);
//                 final displayCategory = category.startsWith('custom_')
//                     ? (rawTitle.isNotEmpty ? rawTitle : category)
//                     : _categoryDisplayName(category);
//                 final amount = (data['amount'] as num).toDouble();

//                 return pw.TableRow(
//                   decoration: pw.BoxDecoration(color: cardColor),
//                   children: [
//                     _tableCell(DateFormat('dd MMM').format(date), subtextColor),
//                     _tableCell(title, textColor),
//                     _tableCell(displayCategory, subtextColor),
//                     _tableCell(
//                       '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
//                       isIncome ? incomeColor : expenseColor,
//                     ),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );

//     return Uint8List.fromList(await pdf.save());
//   }

//   // ─────────────────────────────────────────────
//   // PREVIEW PDF
//   // ─────────────────────────────────────────────
//   static Future<void> previewReport({
//     required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
//     required DateTimeRange range,
//     required String partnerName,
//     required BuildContext context,
//   }) async {
//     final bytes = await generateReport(
//       expenses: expenses,
//       range: range,
//       partnerName: partnerName,
//     );

//     if (!context.mounted) return;

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => _PdfPreviewScreen(bytes: bytes),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   // DOWNLOAD / SHARE PDF
//   // ─────────────────────────────────────────────
//   static Future<void> downloadReport({
//     required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
//     required DateTimeRange range,
//     required String partnerName,
//     required BuildContext context,
//   }) async {
//     final bytes = await generateReport(
//       expenses: expenses,
//       range: range,
//       partnerName: partnerName,
//     );

//     final fileName =
//         'expense_report_${DateFormat('yyyyMMdd').format(range.start)}_${DateFormat('yyyyMMdd').format(range.end)}.pdf';

//     await Printing.sharePdf(bytes: bytes, filename: fileName);
//   }

//   // ─────────────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────────────
//   static pw.Widget _summaryCard(
//     String label,
//     String value,
//     PdfColor valueColor,
//     PdfColor bgColor,
//     PdfColor textColor,
//     PdfColor subtextColor,
//   ) {
//     return pw.Expanded(
//       child: pw.Container(
//         padding: const pw.EdgeInsets.all(12),
//         decoration: pw.BoxDecoration(
//           color: bgColor,
//           borderRadius: pw.BorderRadius.circular(10),
//         ),
//         child: pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(label,
//                 style: pw.TextStyle(color: subtextColor, fontSize: 10)),
//             pw.SizedBox(height: 6),
//             pw.Text(
//               value,
//               style: pw.TextStyle(
//                 color: valueColor,
//                 fontSize: 14,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static pw.Widget _tableHeader(String text, PdfColor color) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//             color: color, fontSize: 11, fontWeight: pw.FontWeight.bold),
//       ),
//     );
//   }

//   static pw.Widget _tableCell(String text, PdfColor color) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
//       child: pw.Text(text, style: pw.TextStyle(color: color, fontSize: 11)),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // PDF PREVIEW SCREEN (outside PdfService class)
// // ─────────────────────────────────────────────
// class _PdfPreviewScreen extends StatelessWidget {
//   final Uint8List bytes;
//   const _PdfPreviewScreen({required this.bytes});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B1120),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0B1120),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               color: Colors.white, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Report Preview',
//           style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share, color: Colors.white),
//             onPressed: () async {
//               await Printing.sharePdf(
//                 bytes: bytes,
//                 filename: 'expense_report.pdf',
//               );
//             },
//           ),
//         ],
//       ),
//       body: PdfPreview(
//         build: (_) async => bytes,
//         allowPrinting: false,
//         allowSharing: false,
//         canChangePageFormat: false,
//         canChangeOrientation: false,
//         canDebug: false,
//         pdfFileName: 'expense_report.pdf',
//         actions: const [],
//       ),
//     );
//   }
// }

// claude 

// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:typed_data';

// import '../constants/active_partner.dart';

// class PdfService {
//   static String _formatCurrency(double amount) =>
//       'Rs. ${amount.toStringAsFixed(0)}';

//   static String _formatDate(DateTime date) =>
//       DateFormat('dd MMM yyyy').format(date);

//   static String _categoryDisplayName(String id) {
//     const names = {
//       'food': 'Food',
//       'travel': 'Travel',
//       'shopping': 'Shopping',
//       'fuel': 'Fuel',
//       'maintenance': 'Maintenance',
//       'lodging': 'Lodging',
//       'office': 'Office',
//       'other_expense': 'Others',
//       'salary': 'Salary',
//       'freelance': 'Freelance',
//       'other_income': 'Others',
//     };
//     return names[id] ?? id;
//   }

//   // Resolves any category ID to a display name
//   static String _resolveCategoryName(
//     String category,
//     Map<String, String> customCategoryNames,
//   ) {
//     if (customCategoryNames.containsKey(category)) {
//       return customCategoryNames[category]!;
//     }
//     return _categoryDisplayName(category);
//   }

//   // ─────────────────────────────────────────────
//   // FETCH CUSTOM CATEGORY NAMES FRESH FROM FIRESTORE
//   // ─────────────────────────────────────────────
//   static Future<Map<String, String>> _fetchCustomCategoryNames() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('partners')
//         .doc(activePartnerId)
//         .collection('customCategories')
//         .get();

//     final map = <String, String>{};
//     for (final doc in snapshot.docs) {
//       final name = doc.data()['name'] as String?;
//       if (name != null) {
//         map[doc.id] = name;
//       }
//     }
//     return map;
//   }

//   // ─────────────────────────────────────────────
//   // GENERATE PDF BYTES
//   // ─────────────────────────────────────────────
//   static Future<Uint8List> generateReport({
//     required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
//     required DateTimeRange range,
//     required String partnerName,
//     // Still accepted for backward compat but we always re-fetch fresh
//     Map<String, String> customCategoryNames = const {},
//   }) async {
//     final pdf = pw.Document();

//     // Always fetch fresh from Firestore so names are never stale/empty
//     final resolvedNames = await _fetchCustomCategoryNames();

//     // Merge passed-in map with fetched (fetched takes priority)
//     final allNames = {...customCategoryNames, ...resolvedNames};

//     // Filter to range
//     final filtered = expenses.where((doc) {
//       final data = doc.data();
//       final ts = data['createdAt'] as Timestamp?;
//       if (ts == null) return false;
//       final date = ts.toDate();
//       return !date.isBefore(range.start) && !date.isAfter(range.end);
//     }).toList();

//     // Totals
//     double totalIncome = 0;
//     double totalExpense = 0;
//     final Map<String, double> categoryTotals = {};

//     for (final doc in filtered) {
//       final data = doc.data();
//       final amount = (data['amount'] as num).toDouble();
//       final type = data['type'] as String;
//       final category = data['category'] as String;

//       if (type == 'income') {
//         totalIncome += amount;
//       } else {
//         totalExpense += amount;
//         final key = _resolveCategoryName(category, allNames);
//         categoryTotals[key] = (categoryTotals[key] ?? 0) + amount;
//       }
//     }

//     final balance = totalIncome - totalExpense;

//     final sortedCategories = categoryTotals.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     // PDF Colors
//     const primaryColor = PdfColor.fromInt(0xFF6366F1);
//     const incomeColor = PdfColor.fromInt(0xFF22C55E);
//     const expenseColor = PdfColor.fromInt(0xFFEF4444);
//     const bgColor = PdfColor.fromInt(0xFF111827);
//     const cardColor = PdfColor.fromInt(0xFF1F2937);
//     const textColor = PdfColor.fromInt(0xFFFFFFFF);
//     const subtextColor = PdfColor.fromInt(0xFF9CA3AF);

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         maxPages: 999,
//         build: (pw.Context context) => [
//           // ── HEADER ──
//           pw.Container(
//             padding: const pw.EdgeInsets.all(20),
//             decoration: pw.BoxDecoration(
//               color: bgColor,
//               borderRadius: pw.BorderRadius.circular(16),
//             ),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           partnerName.isNotEmpty
//                               ? partnerName
//                               : 'Partner Ledger',
//                           style: pw.TextStyle(
//                             color: textColor,
//                             fontSize: 22,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(height: 4),
//                         pw.Text(
//                           'Expense Report',
//                           style:
//                               pw.TextStyle(color: subtextColor, fontSize: 13),
//                         ),
//                       ],
//                     ),
//                     pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       decoration: pw.BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: pw.BorderRadius.circular(8),
//                       ),
//                       child: pw.Text(
//                         '${_formatDate(range.start)} - ${_formatDate(range.end)}',
//                         style: pw.TextStyle(color: textColor, fontSize: 11),
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Text(
//                   'Generated on ${_formatDate(DateTime.now())}',
//                   style: pw.TextStyle(color: subtextColor, fontSize: 11),
//                 ),
//               ],
//             ),
//           ),

//           pw.SizedBox(height: 20),

//           // ── SUMMARY CARDS ──
//           pw.Row(
//             children: [
//               _summaryCard('Total Income', _formatCurrency(totalIncome),
//                   incomeColor, cardColor, textColor, subtextColor),
//               pw.SizedBox(width: 12),
//               _summaryCard('Total Expenses', _formatCurrency(totalExpense),
//                   expenseColor, cardColor, textColor, subtextColor),
//               pw.SizedBox(width: 12),
//               _summaryCard(
//                 'Net Balance',
//                 _formatCurrency(balance),
//                 balance >= 0 ? incomeColor : expenseColor,
//                 cardColor,
//                 textColor,
//                 subtextColor,
//               ),
//               pw.SizedBox(width: 12),
//               _summaryCard('Transactions', '${filtered.length}', primaryColor,
//                   cardColor, textColor, subtextColor),
//             ],
//           ),

//           pw.SizedBox(height: 20),

//           // ── CATEGORY BREAKDOWN ──
//           if (sortedCategories.isNotEmpty) ...[
//             pw.Container(
//               padding: const pw.EdgeInsets.all(16),
//               decoration: pw.BoxDecoration(
//                 color: cardColor,
//                 borderRadius: pw.BorderRadius.circular(12),
//               ),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'Spending by Category',
//                     style: pw.TextStyle(
//                       color: textColor,
//                       fontSize: 15,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.SizedBox(height: 12),
//                   pw.Table(
//                     columnWidths: {
//                       0: const pw.FlexColumnWidth(3),
//                       1: const pw.FlexColumnWidth(2),
//                       2: const pw.FlexColumnWidth(2),
//                     },
//                     children: [
//                       pw.TableRow(
//                         decoration: pw.BoxDecoration(
//                           border: pw.Border(
//                             bottom: pw.BorderSide(
//                                 color: subtextColor, width: 0.5),
//                           ),
//                         ),
//                         children: [
//                           _tableHeader('Category', subtextColor),
//                           _tableHeader('Amount', subtextColor),
//                           _tableHeader('% of Total', subtextColor),
//                         ],
//                       ),
//                       ...sortedCategories.map((e) {
//                         final pct = totalExpense > 0
//                             ? (e.value / totalExpense * 100)
//                                 .toStringAsFixed(1)
//                             : '0.0';
//                         return pw.TableRow(
//                           children: [
//                             _tableCell(e.key, textColor),
//                             _tableCell(
//                                 _formatCurrency(e.value), expenseColor),
//                             _tableCell('$pct%', subtextColor),
//                           ],
//                         );
//                       }),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             pw.SizedBox(height: 20),
//           ],

//           // ── TRANSACTION LIST ──
//           pw.Table(
//             columnWidths: {
//               0: const pw.FlexColumnWidth(2),
//               1: const pw.FlexColumnWidth(3),
//               2: const pw.FlexColumnWidth(2),
//               3: const pw.FlexColumnWidth(2),
//             },
//             children: [
//               // Section title row
//               pw.TableRow(
//                 decoration: pw.BoxDecoration(color: cardColor),
//                 children: [
//                   pw.Padding(
//                     padding:
//                         const pw.EdgeInsets.fromLTRB(12, 14, 12, 10),
//                     child: pw.Text(
//                       'All Transactions',
//                       style: pw.TextStyle(
//                         color: textColor,
//                         fontSize: 15,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   pw.SizedBox(),
//                   pw.SizedBox(),
//                   pw.SizedBox(),
//                 ],
//               ),
//               // Column headers
//               pw.TableRow(
//                 decoration: pw.BoxDecoration(
//                   color: cardColor,
//                   border: pw.Border(
//                     bottom:
//                         pw.BorderSide(color: subtextColor, width: 0.5),
//                   ),
//                 ),
//                 children: [
//                   _tableHeader('Date', subtextColor),
//                   _tableHeader('Title', subtextColor),
//                   _tableHeader('Category', subtextColor),
//                   _tableHeader('Amount', subtextColor),
//                 ],
//               ),
//               // Data rows
//               ...filtered.map((doc) {
//                 final data = doc.data();
//                 final ts = data['createdAt'] as Timestamp?;
//                 final date = ts?.toDate() ?? DateTime.now();
//                 final isIncome = data['type'] == 'income';
//                 final rawTitle = data['title'] as String? ?? '';
//                 final category = data['category'] as String? ?? '';

//                 final displayCategory =
//                     _resolveCategoryName(category, allNames);

//                 final title = rawTitle.isNotEmpty ? rawTitle : displayCategory;

//                 final amount = (data['amount'] as num).toDouble();

//                 return pw.TableRow(
//                   decoration: pw.BoxDecoration(color: cardColor),
//                   children: [
//                     _tableCell(
//                         DateFormat('dd MMM').format(date), subtextColor),
//                     _tableCell(title, textColor),
//                     _tableCell(displayCategory, subtextColor),
//                     _tableCell(
//                       '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
//                       isIncome ? incomeColor : expenseColor,
//                     ),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );

//     return Uint8List.fromList(await pdf.save());
//   }

//   // ─────────────────────────────────────────────
//   // PREVIEW PDF
//   // ─────────────────────────────────────────────
//   static Future<void> previewReport({
//     required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
//     required DateTimeRange range,
//     required String partnerName,
//     Map<String, String> customCategoryNames = const {},
//     required BuildContext context,
//   }) async {
//     final bytes = await generateReport(
//       expenses: expenses,
//       range: range,
//       partnerName: partnerName,
//       customCategoryNames: customCategoryNames,
//     );

//     if (!context.mounted) return;

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => _PdfPreviewScreen(bytes: bytes),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   // DOWNLOAD / SHARE PDF
//   // ─────────────────────────────────────────────
//   static Future<void> downloadReport({
//     required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
//     required DateTimeRange range,
//     required String partnerName,
//     Map<String, String> customCategoryNames = const {},
//     required BuildContext context,
//   }) async {
//     final bytes = await generateReport(
//       expenses: expenses,
//       range: range,
//       partnerName: partnerName,
//       customCategoryNames: customCategoryNames,
//     );

//     final fileName =
//         'expense_report_${DateFormat('yyyyMMdd').format(range.start)}_${DateFormat('yyyyMMdd').format(range.end)}.pdf';

//     await Printing.sharePdf(bytes: bytes, filename: fileName);
//   }

//   // ─────────────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────────────
//   static pw.Widget _summaryCard(
//     String label,
//     String value,
//     PdfColor valueColor,
//     PdfColor bgColor,
//     PdfColor textColor,
//     PdfColor subtextColor,
//   ) {
//     return pw.Expanded(
//       child: pw.Container(
//         padding: const pw.EdgeInsets.all(12),
//         decoration: pw.BoxDecoration(
//           color: bgColor,
//           borderRadius: pw.BorderRadius.circular(10),
//         ),
//         child: pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(label,
//                 style: pw.TextStyle(color: subtextColor, fontSize: 10)),
//             pw.SizedBox(height: 6),
//             pw.Text(
//               value,
//               style: pw.TextStyle(
//                 color: valueColor,
//                 fontSize: 14,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static pw.Widget _tableHeader(String text, PdfColor color) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//             color: color, fontSize: 11, fontWeight: pw.FontWeight.bold),
//       ),
//     );
//   }

//   static pw.Widget _tableCell(String text, PdfColor color) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
//       child: pw.Text(text, style: pw.TextStyle(color: color, fontSize: 11)),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // PDF PREVIEW SCREEN
// // ─────────────────────────────────────────────
// class _PdfPreviewScreen extends StatelessWidget {
//   final Uint8List bytes;
//   const _PdfPreviewScreen({required this.bytes});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B1120),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0B1120),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               color: Colors.white, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Report Preview',
//           style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share, color: Colors.white),
//             onPressed: () async {
//               await Printing.sharePdf(
//                 bytes: bytes,
//                 filename: 'expense_report.pdf',
//               );
//             },
//           ),
//         ],
//       ),
//       body: PdfPreview(
//         build: (_) async => bytes,
//         allowPrinting: false,
//         allowSharing: false,
//         canChangePageFormat: false,
//         canChangeOrientation: false,
//         canDebug: false,
//         pdfFileName: 'expense_report.pdf',
//         actions: const [],
//       ),
//     );
//   }
// }

//10 may


import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

import '../constants/active_partner.dart';

class PdfService {
  static String _formatCurrency(double amount) =>
      'Rs. ${amount.toStringAsFixed(0)}';

  static String _formatDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String _categoryDisplayName(String id) {
    const names = {
      'food': 'Food',
      'travel': 'Travel',
      'shopping': 'Shopping',
      'fuel': 'Fuel',
      'maintenance': 'Maintenance',
      'lodging': 'Lodging',
      'office': 'Office',
      'other_expense': 'Others',
      'salary': 'Salary',
      'freelance': 'Freelance',
      'other_income': 'Others',
    };
    return names[id] ?? id;
  }

  static String _resolveCategoryName(
    String category,
    Map<String, String> customCategoryNames,
  ) {
    if (customCategoryNames.containsKey(category)) {
      return customCategoryNames[category]!;
    }
    return _categoryDisplayName(category);
  }

  /// Resolve a paidBy UID to a display name.
  /// Falls back to the raw UID if not found in either map.
  static String _resolvePersonName(
    String uid,
    Map<String, String> uidToName,
  ) {
    return uidToName[uid] ?? uid;
  }

  // ─────────────────────────────────────────────
  // FETCH CUSTOM CATEGORY NAMES FRESH FROM FIRESTORE
  // ─────────────────────────────────────────────
  static Future<Map<String, String>> _fetchCustomCategoryNames() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('partners')
        .doc(activePartnerId)
        .collection('customCategories')
        .get();

    final map = <String, String>{};
    for (final doc in snapshot.docs) {
      final name = doc.data()['name'] as String?;
      if (name != null) {
        map[doc.id] = name;
      }
    }
    return map;
  }

  // ─────────────────────────────────────────────
  // FETCH UID→NAME MAP FRESH FROM FIRESTORE
  // ─────────────────────────────────────────────
  static Future<Map<String, String>> _fetchUidToName() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    final map = <String, String>{};
    for (final doc in snapshot.docs) {
      final name = doc.data()['name'] as String?;
      if (name != null && name.trim().isNotEmpty) {
        map[doc.id] = name.trim();
      }
    }
    return map;
  }

  // ─────────────────────────────────────────────
  // GENERATE PDF BYTES
  //
  // [personFilter] is a display NAME (e.g. "Dhanaji Arage") or null for all.
  // [uidToName]   is passed in from the UI layer (uid → name map).
  // ─────────────────────────────────────────────
  static Future<Uint8List> generateReport({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
    required DateTimeRange range,
    required String partnerName,
    Map<String, String> customCategoryNames = const {},
    // null = all people; non-null = individual person NAME
    String? personFilter,
    Map<String, String> uidToName = const {},
  }) async {
    final pdf = pw.Document();

    // Always fetch fresh from Firestore so names are never stale/empty
    final resolvedNames = await _fetchCustomCategoryNames();
    final allNames = {...customCategoryNames, ...resolvedNames};

    // Merge passed-in uidToName with a fresh fetch for safety
    final freshUidToName = await _fetchUidToName();
    final resolvedUidToName = {...uidToName, ...freshUidToName};

    // Filter to date range
    var filtered = expenses.where((doc) {
      final data = doc.data();
      final ts = data['createdAt'] as Timestamp?;
      if (ts == null) return false;
      final date = ts.toDate();
      return !date.isBefore(range.start) && !date.isAfter(range.end);
    }).toList();

    // Filter by person — personFilter is a NAME; find matching UIDs
    if (personFilter != null) {
      final matchingUids = resolvedUidToName.entries
          .where((e) => e.value == personFilter)
          .map((e) => e.key)
          .toSet();

      filtered = filtered
          .where((doc) => matchingUids.contains(doc.data()['paidBy']))
          .toList();
    }

    // Totals
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryTotals = {};

    for (final doc in filtered) {
      final data = doc.data();
      final amount = (data['amount'] as num).toDouble();
      final type = data['type'] as String;
      final category = data['category'] as String;

      if (type == 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
        final key = _resolveCategoryName(category, allNames);
        categoryTotals[key] = (categoryTotals[key] ?? 0) + amount;
      }
    }

    final balance = totalIncome - totalExpense;

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // PDF Colors
    const primaryColor = PdfColor.fromInt(0xFF6366F1);
    const incomeColor = PdfColor.fromInt(0xFF22C55E);
    const expenseColor = PdfColor.fromInt(0xFFEF4444);
    const bgColor = PdfColor.fromInt(0xFF111827);
    const cardColor = PdfColor.fromInt(0xFF1F2937);
    const textColor = PdfColor.fromInt(0xFFFFFFFF);
    const subtextColor = PdfColor.fromInt(0xFF9CA3AF);
    const badgeColor = PdfColor.fromInt(0xFF374151);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 999,
        build: (pw.Context context) => [
          // ── HEADER ──
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: bgColor,
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          partnerName.isNotEmpty
                              ? partnerName
                              : 'Partner Ledger',
                          style: pw.TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          personFilter != null
                              ? 'Individual Report — $personFilter'
                              : 'Expense Report',
                          style: pw.TextStyle(
                              color: subtextColor, fontSize: 13),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Text(
                            '${_formatDate(range.start)} – ${_formatDate(range.end)}',
                            style: pw.TextStyle(
                                color: textColor, fontSize: 11),
                          ),
                        ),
                        if (personFilter != null) ...[
                          pw.SizedBox(height: 6),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: badgeColor,
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Text(
                              // personFilter is already a name
                              '$personFilter',
                              style: pw.TextStyle(
                                  color: subtextColor, fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${_formatDate(DateTime.now())}',
                  style: pw.TextStyle(color: subtextColor, fontSize: 11),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── SUMMARY CARDS ──
          pw.Row(
            children: [
              _summaryCard('Total Income', _formatCurrency(totalIncome),
                  incomeColor, cardColor, textColor, subtextColor),
              pw.SizedBox(width: 12),
              _summaryCard('Total Expenses', _formatCurrency(totalExpense),
                  expenseColor, cardColor, textColor, subtextColor),
              pw.SizedBox(width: 12),
              _summaryCard(
                'Net Balance',
                _formatCurrency(balance),
                balance >= 0 ? incomeColor : expenseColor,
                cardColor,
                textColor,
                subtextColor,
              ),
              pw.SizedBox(width: 12),
              _summaryCard('Transactions', '${filtered.length}',
                  primaryColor, cardColor, textColor, subtextColor),
            ],
          ),

          pw.SizedBox(height: 20),

          // ── CATEGORY BREAKDOWN ──
          if (sortedCategories.isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: cardColor,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Spending by Category',
                    style: pw.TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                                color: subtextColor, width: 0.5),
                          ),
                        ),
                        children: [
                          _tableHeader('Category', subtextColor),
                          _tableHeader('Amount', subtextColor),
                          _tableHeader('% of Total', subtextColor),
                        ],
                      ),
                      ...sortedCategories.map((e) {
                        final pct = totalExpense > 0
                            ? (e.value / totalExpense * 100)
                                .toStringAsFixed(1)
                            : '0.0';
                        return pw.TableRow(
                          children: [
                            _tableCell(e.key, textColor),
                            _tableCell(
                                _formatCurrency(e.value), expenseColor),
                            _tableCell('$pct%', subtextColor),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // ── TRANSACTION LIST ──
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              // Show "Paid By" column only when showing all people
              if (personFilter == null) 4: const pw.FlexColumnWidth(2),
            },
            children: [
              // Section title row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: cardColor),
                children: [
                  pw.Padding(
                    padding:
                        const pw.EdgeInsets.fromLTRB(12, 14, 12, 10),
                    child: pw.Text(
                      personFilter != null
                          ? 'Transactions — $personFilter'
                          : 'All Transactions',
                      style: pw.TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(),
                  pw.SizedBox(),
                  pw.SizedBox(),
                  if (personFilter == null) pw.SizedBox(),
                ],
              ),
              // Column headers
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: cardColor,
                  border: pw.Border(
                    bottom:
                        pw.BorderSide(color: subtextColor, width: 0.5),
                  ),
                ),
                children: [
                  _tableHeader('Date', subtextColor),
                  _tableHeader('Title', subtextColor),
                  _tableHeader('Category', subtextColor),
                  _tableHeader('Amount', subtextColor),
                  if (personFilter == null)
                    _tableHeader('Paid By', subtextColor),
                ],
              ),
              // Data rows
              ...filtered.map((doc) {
                final data = doc.data();
                final ts = data['createdAt'] as Timestamp?;
                final date = ts?.toDate() ?? DateTime.now();
                final isIncome = data['type'] == 'income';
                final rawTitle = data['title'] as String? ?? '';
                final category = data['category'] as String? ?? '';
                final paidByUid = data['paidBy'] as String? ?? '';

                final displayCategory =
                    _resolveCategoryName(category, allNames);
                final title =
                    rawTitle.isNotEmpty ? rawTitle : displayCategory;
                final amount = (data['amount'] as num).toDouble();

                // Resolve UID → display name for "Paid By" column
                final paidByName = paidByUid.isNotEmpty
                    ? _resolvePersonName(paidByUid, resolvedUidToName)
                    : '—';

                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: cardColor),
                  children: [
                    _tableCell(
                        DateFormat('dd MMM').format(date), subtextColor),
                    _tableCell(title, textColor),
                    _tableCell(displayCategory, subtextColor),
                    _tableCell(
                      '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
                      isIncome ? incomeColor : expenseColor,
                    ),
                    if (personFilter == null)
                      _tableCell(paidByName, subtextColor),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  // ─────────────────────────────────────────────
  // PREVIEW PDF
  // ─────────────────────────────────────────────
  static Future<void> previewReport({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
    required DateTimeRange range,
    required String partnerName,
    Map<String, String> customCategoryNames = const {},
    String? personFilter,
    Map<String, String> uidToName = const {},
    required BuildContext context,
  }) async {
    final bytes = await generateReport(
      expenses: expenses,
      range: range,
      partnerName: partnerName,
      customCategoryNames: customCategoryNames,
      personFilter: personFilter,
      uidToName: uidToName,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PdfPreviewScreen(
          bytes: bytes,
          personFilter: personFilter,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DOWNLOAD / SHARE PDF
  // ─────────────────────────────────────────────
  static Future<void> downloadReport({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
    required DateTimeRange range,
    required String partnerName,
    Map<String, String> customCategoryNames = const {},
    String? personFilter,
    Map<String, String> uidToName = const {},
    required BuildContext context,
  }) async {
    final bytes = await generateReport(
      expenses: expenses,
      range: range,
      partnerName: partnerName,
      customCategoryNames: customCategoryNames,
      personFilter: personFilter,
      uidToName: uidToName,
    );

    // personFilter is a name — safe to use directly in filename
    final personSuffix = personFilter != null
        ? '_${personFilter.replaceAll(' ', '_')}'
        : '';
    final fileName =
        'expense_report${personSuffix}_${DateFormat('yyyyMMdd').format(range.start)}_${DateFormat('yyyyMMdd').format(range.end)}.pdf';

    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  static pw.Widget _summaryCard(
    String label,
    String value,
    PdfColor valueColor,
    PdfColor bgColor,
    PdfColor textColor,
    PdfColor subtextColor,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(color: subtextColor, fontSize: 10)),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tableHeader(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            color: color, fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _tableCell(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: pw.Text(text, style: pw.TextStyle(color: color, fontSize: 11)),
    );
  }
}

// ─────────────────────────────────────────────
// PDF PREVIEW SCREEN
// ─────────────────────────────────────────────
class _PdfPreviewScreen extends StatelessWidget {
  final Uint8List bytes;
  final String? personFilter;

  const _PdfPreviewScreen({
    required this.bytes,
    this.personFilter,
  });

  @override
  Widget build(BuildContext context) {
    // personFilter is already a display name (e.g. "Dhanaji Arage")
    final title = personFilter != null
        ? '$personFilter — Report'
        : 'Report Preview';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              final safeName = personFilter != null
                  ? personFilter!.replaceAll(' ', '_')
                  : null;
              final fileName = safeName != null
                  ? 'report_$safeName.pdf'
                  : 'expense_report.pdf';
              await Printing.sharePdf(bytes: bytes, filename: fileName);
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) async => bytes,
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: personFilter != null
            ? 'report_${personFilter!.replaceAll(' ', '_')}.pdf'
            : 'expense_report.pdf',
        actions: const [],
      ),
    );
  }
}