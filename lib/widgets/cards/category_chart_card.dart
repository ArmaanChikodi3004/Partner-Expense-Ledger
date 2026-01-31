import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../charts/category_donut_chart.dart';

class CategoryChartCard extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses;

  const CategoryChartCard({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111827).withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- TITLE ----------------
              const Text(
                'Spending by Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- CHART ----------------
              CategoryDonutChart(
                categoryTotals: categoryTotals,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔒 CORE LOGIC — EXPENSE ONLY
  Map<String, double> _calculateCategoryTotals() {
    final Map<String, double> totals = {};

    for (final doc in expenses) {
      final data = doc.data();

      // ❌ Ignore income completely
      if (data['type'] != 'expense') continue;

      final category = data['category'] as String;
      final amount = (data['amount'] as num).toDouble();

      totals[category] = (totals[category] ?? 0) + amount;
    }

    return totals;
  }
}
