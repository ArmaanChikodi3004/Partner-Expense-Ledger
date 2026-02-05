import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/navigation/bottom_nav.dart';
import '../../widgets/balance/balance_card.dart';
import '../../widgets/cards/category_chart_card.dart';
import '../../widgets/transactions/transaction_list.dart';
import '../../widgets/entry/add_entry_sheet.dart';

import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

import '../../services/expense_service.dart';
import '../../constants/active_partner.dart';
import '../../services/user_service.dart';

enum HomeTab { home, reports, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab activeTab = HomeTab.home;
  final Set<String> selectedUserUids = {'ALL'};
  DateFilter activeDateFilter = DateFilter.last7Days;

  bool _matchesDate(DateTime date) {
    final now = DateTime.now();
    DateTime start;

    switch (activeDateFilter) {
      case DateFilter.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case DateFilter.last2Days:
        start = now.subtract(const Duration(days: 2));
        break;
      case DateFilter.last7Days:
        start = now.subtract(const Duration(days: 7));
        break;
      case DateFilter.last15Days:
        start = now.subtract(const Duration(days: 15));
        break;
      case DateFilter.lastMonth:
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case DateFilter.custom:
        return true;
    }

    return date.isAfter(start);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E1A),
        elevation: 0,
        title: Image.asset('assets/LOGO_1.png', height: 36),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildTab(),
      ),
      bottomNavigationBar: BottomNav(
        activeTab: activeTab,
        onTabChange: (t) => setState(() => activeTab = t),
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

  Widget _buildTab() {
    switch (activeTab) {
      case HomeTab.home:
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ExpenseService.getExpenses(partnerId: activePartnerId),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final all = snapshot.data!.docs;

            final userFiltered = selectedUserUids.contains('ALL')
                ? all
                : all.where((d) => selectedUserUids.contains(d['paidBy'])).toList();

            final dateFiltered = userFiltered.where((doc) {
              final ts = doc['createdAt'] as Timestamp?;
              if (ts == null) return false;
              return _matchesDate(ts.toDate());
            }).toList();

           // ✅ BALANCE MUST BE FULL FIREBASE DATA (NO DATE FILTER)
double income = 0;
double expense = 0;

for (final d in userFiltered) {
  final amt = (d['amount'] as num).toDouble();
  if (d['type'] == 'income') {
    income += amt;
  } else if (d['type'] == 'expense') {
    expense += amt;
  }
}



            final userUids =
                all.map((d) => d['paidBy'] as String).toSet().toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceCard(
                    balance: (income - expense).toInt(),
                    income: income.toInt(),
                    expense: expense.toInt(),
                  ),
                  const SizedBox(height: 20),
                  _userChips(userUids),
                  const SizedBox(height: 12),
                  CategoryChartCard(expenses: dateFiltered),
                  const SizedBox(height: 20),
                  TransactionList(
                    expenses: dateFiltered,
                    onDateChange: (f) => setState(() => activeDateFilter = f),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            );
          },
        );

      case HomeTab.reports:
        return const ReportsScreen();
      case HomeTab.settings:
        return const SettingsScreen();
    }
  }

  Widget _userChips(List<String> uids) {
    final all = ['ALL', ...uids];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final uid = all[i];
          final active = selectedUserUids.contains(uid);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (uid == 'ALL') {
                  selectedUserUids..clear()..add('ALL');
                } else {
                  selectedUserUids.remove('ALL');
                  active
                      ? selectedUserUids.remove(uid)
                      : selectedUserUids.add(uid);
                  if (selectedUserUids.isEmpty) {
                    selectedUserUids.add('ALL');
                  }
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF6366F1)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: uid == 'ALL'
                  ? const Text('All',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600))
                  : FutureBuilder<String>(
                      future: UserService.getUserName(uid),
                      builder: (_, s) => Text(
                        s.data ?? '...',
                        style: TextStyle(
                          color:
                              active ? Colors.white : Colors.white70,
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
