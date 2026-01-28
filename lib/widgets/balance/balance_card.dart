import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/charts/sparkline_chart.dart';

class BalanceCard extends StatelessWidget {
  final int balance;
  final int income;
  final int expense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  String _formatCurrency(int amount) {
    return '₹$amount';
  }

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
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatCurrency(balance),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Sparkline
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SparklineChart(),
              ),

              const Center(
                child: Text(
                  'Last 7 days',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- INCOME / EXPENSE ----------------
              Row(
                children: [
                  _summaryCard(
                    label: 'Income',
                    amount: income,
                    color: const Color(0xFF6366F1),
                    icon: Icons.arrow_upward,
                  ),
                  const SizedBox(width: 12),
                  _summaryCard(
                    label: 'Expense',
                    amount: expense,
                    color: const Color(0xFFEC4899),
                    icon: Icons.arrow_downward,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SUMMARY CARD ----------------
  Widget _summaryCard({
    required String label,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
