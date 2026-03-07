import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class PdfService {
  // Use "Rs." instead of "₹" — default PDF font has no Unicode support
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

  // ─────────────────────────────────────────────
  // GENERATE PDF BYTES
  // ─────────────────────────────────────────────
  static Future<Uint8List> generateReport({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
    required DateTimeRange range,
    required String partnerName,
  }) async {
    final pdf = pw.Document();

    // Filter to range
    final filtered = expenses.where((doc) {
      final data = doc.data();
      final ts = data['createdAt'] as Timestamp?;
      if (ts == null) return false;
      final date = ts.toDate();
      return !date.isBefore(range.start) && !date.isAfter(range.end);
    }).toList();

    // Totals
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryTotals = {};

    for (final doc in filtered) {
      final data = doc.data();
      final amount = (data['amount'] as num).toDouble();
      final type = data['type'] as String;
      final category = data['category'] as String;
      final title = (data['title'] as String?) ?? '';

      if (type == 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
        final key = category.startsWith('custom_')
            ? (title.isNotEmpty ? title : category)
            : _categoryDisplayName(category);
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
                          'Partner Ledger',
                          style: pw.TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Expense Report',
                          style: pw.TextStyle(color: subtextColor, fontSize: 13),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        '${_formatDate(range.start)} - ${_formatDate(range.end)}',
                        style: pw.TextStyle(color: textColor, fontSize: 11),
                      ),
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
              _summaryCard('Transactions', '${filtered.length}', primaryColor,
                  cardColor, textColor, subtextColor),
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
                            bottom:
                                pw.BorderSide(color: subtextColor, width: 0.5),
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
                  'All Transactions',
                  style: pw.TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
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
                      ],
                    ),
                    ...filtered.map((doc) {
                      final data = doc.data();
                      final ts = data['createdAt'] as Timestamp?;
                      final date = ts?.toDate() ?? DateTime.now();
                      final isIncome = data['type'] == 'income';
                      final rawTitle = data['title'] as String? ?? '';
                      final category = data['category'] as String;
                      final title = rawTitle.isNotEmpty
                          ? rawTitle
                          : _categoryDisplayName(category);
                      final displayCategory = category.startsWith('custom_')
                          ? (rawTitle.isNotEmpty ? rawTitle : category)
                          : _categoryDisplayName(category);
                      final amount = (data['amount'] as num).toDouble();

                      return pw.TableRow(
                        children: [
                          _tableCell(
                              DateFormat('dd MMM').format(date), subtextColor),
                          _tableCell(title, textColor),
                          _tableCell(displayCategory, subtextColor),
                          _tableCell(
                            '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
                            isIncome ? incomeColor : expenseColor,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
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
    required BuildContext context,
  }) async {
    final bytes = await generateReport(
      expenses: expenses,
      range: range,
      partnerName: partnerName,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  // ─────────────────────────────────────────────
  // SAVE & SHARE PDF
  // ─────────────────────────────────────────────
  static Future<void> downloadReport({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
    required DateTimeRange range,
    required String partnerName,
    required BuildContext context,
  }) async {
    final bytes = await generateReport(
      expenses: expenses,
      range: range,
      partnerName: partnerName,
    );

    final fileName =
        'expense_report_${DateFormat('yyyyMMdd').format(range.start)}_${DateFormat('yyyyMMdd').format(range.end)}.pdf';

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
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            color: color, fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _tableCell(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Text(text, style: pw.TextStyle(color: color, fontSize: 11)),
    );
  }
}