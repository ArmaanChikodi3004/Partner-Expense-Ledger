import 'dart:ui';
import 'package:flutter/material.dart';
import '../charts/category_donut_chart.dart';

class CategoryChartCard extends StatelessWidget {
  const CategoryChartCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            children: const [
              // ---------------- TITLE ----------------
              Text(
                'Spending by Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 20),

              // ---------------- CHART ----------------
              CategoryDonutChart(),
            ],
          ),
        ),
      ),
    );
  }
}
