import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/navigation/bottom_nav.dart';
import '../../widgets/balance/balance_card.dart';
import '../../widgets/cards/category_chart_card.dart';
import '../../widgets/transactions/transaction_list.dart';
import '../../widgets/entry/add_entry_sheet.dart';

import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../attachments/attachments_screen.dart'; // ✅ CORRECT

import '../../services/expense_service.dart';
import '../../constants/active_partner.dart';
import '../../services/user_service.dart';

enum HomeTab { home, reports, attachments, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab activeTab = HomeTab.home;

  // 🔥 STORE SELECTED USER *UIDs*
  final Set<String> selectedUserUids = {'ALL'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E1A),
        elevation: 0,
        title: Image.asset('assets/LOGO_1.png', height: 36),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildActiveTab(),
        ),
      ),

      bottomNavigationBar: BottomNav(
        activeTab: activeTab,
        onTabChange: (tab) => setState(() => activeTab = tab),
        onFabClick: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddEntrySheet(),
          );
        },
      ),
    );
  }

  Widget _buildActiveTab() {
  switch (activeTab) {
    case HomeTab.home:
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ExpenseService.getExpenses(
          partnerId: activePartnerId,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final allExpenses = snapshot.data!.docs;

          final filteredExpenses = selectedUserUids.contains('ALL')
              ? allExpenses
              : allExpenses
                  .where((doc) =>
                      selectedUserUids.contains(doc['paidBy']))
                  .toList();

          double income = 0;
          double expense = 0;

          for (final doc in filteredExpenses) {
            final data = doc.data();
            final amount = (data['amount'] as num).toDouble();

            if (data['type'] == 'income') {
              income += amount;
            } else if (data['type'] == 'expense') {
              expense += amount;
            }
          }

          final balance = income - expense;

          final userUids = allExpenses
              .map((doc) => doc['paidBy'] as String)
              .toSet()
              .toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BalanceCard(
                  balance: balance.toInt(),
                  income: income.toInt(),
                  expense: expense.toInt(),
                ),
                const SizedBox(height: 20),
                _userMultiSelectChips(userUids),
                const SizedBox(height: 12),
                CategoryChartCard(expenses: filteredExpenses),
                const SizedBox(height: 20),
                TransactionList(expenses: filteredExpenses),
                const SizedBox(height: 110),
              ],
            ),
          );
        },
      );

    case HomeTab.reports:
      return const ReportsScreen();

    case HomeTab.attachments:
  return const AttachmentsScreen();

    case HomeTab.settings:
      return const SettingsScreen();
  }
}


  // ---------------- MULTI-SELECT USER CHIPS ----------------
  Widget _userMultiSelectChips(List<String> userUids) {
    final all = ['ALL', ...userUids];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final uid = all[index];
          final isActive = selectedUserUids.contains(uid);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (uid == 'ALL') {
                  selectedUserUids
                    ..clear()
                    ..add('ALL');
                } else {
                  selectedUserUids.remove('ALL');
                  isActive
                      ? selectedUserUids.remove(uid)
                      : selectedUserUids.add(uid);

                  if (selectedUserUids.isEmpty) {
                    selectedUserUids.add('ALL');
                  }
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6366F1)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: uid == 'ALL'
                  ? const Text(
                      'All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : FutureBuilder<String>(
                      future: UserService.getUserName(uid),
                      builder: (_, snap) => Text(
                        snap.data ?? '...',
                        style: TextStyle(
                          color:
                              isActive ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
