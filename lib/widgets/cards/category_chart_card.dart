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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Spending by Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              CategoryDonutChart(categoryTotals: categoryTotals),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals() {
  final Map<String, double> totals = {};

  for (final doc in expenses) {
    final data = doc.data();
    if (data['type'] != 'expense') continue;

    final category = data['category'] as String;
    final amount = (data['amount'] as num).toDouble();

    // For custom categories (Firestore doc IDs), use the title as the key
    // For built-in categories (food, travel etc.), use the id
    final String key = (data['title'] != null &&
                        data['title'].toString().trim().isNotEmpty &&
                        !['food','travel','shopping','fuel','maintenance',
                           'lodging','office','other_expense',
                           'salary','freelance','other_income'].contains(category))
        ? data['title'] as String
        : category;

    totals[key] = (totals[key] ?? 0) + amount;
  }

  return totals;
}
}
