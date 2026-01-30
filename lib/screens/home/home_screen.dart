import 'package:flutter/material.dart';
import '../../widgets/navigation/bottom_nav.dart';
import '../../widgets/balance/balance_card.dart';
import '../../widgets/cards/category_chart_card.dart';
import '../../widgets/transactions/transaction_list.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/entry/add_entry_sheet.dart';

// 🔹 NEW
import '../../services/partner_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum HomeTab { home, reports, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab activeTab = HomeTab.home;

  // ✅ MULTI-SELECT USER FILTER
  final Set<String> selectedUsers = {'All'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),

      // ---------------- HEADER ----------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E1A),
        elevation: 0,
        title: GestureDetector(
          onTap: () => setState(() => activeTab = HomeTab.home),
          child: Image.asset(
            'assets/LOGO_1.png',
            height: 36,
          ),
        ),
      ),

      // ---------------- BODY ----------------
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildActiveTab(),
          ),
        ),
      ),

      // ---------------- BOTTOM NAV ----------------
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

  // ---------------- TAB CONTENT ----------------

  Widget _buildActiveTab() {
    switch (activeTab) {
      case HomeTab.home:
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BalanceCard(
                balance: 12500,
                income: 18000,
                expense: 5500,
              ),

              const SizedBox(height: 20),

              // ---------------- SPENDING BY CATEGORY ----------------
              _spendingCategorySection(),

              const SizedBox(height: 20),

              const TransactionList(),

              const SizedBox(height: 20),

              // 🔥 TEMP TEST BUTTON (Step 7.2)
              ElevatedButton(
  onPressed: () async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final partnerId = await PartnerService.createPartner(
        name: 'Demo Partner Group',
        memberUids: [uid],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Partner created: $partnerId'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: const Text('Create Demo Partner'),
),


              const SizedBox(height: 110),
            ],
          ),
        );

      case HomeTab.reports:
        return const ReportsScreen();

      case HomeTab.settings:
        return const SettingsScreen();
    }
  }

  // ---------------- SPENDING CATEGORY SECTION ----------------

  Widget _spendingCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _userMultiSelectChips(),
        const SizedBox(height: 12),
        const CategoryChartCard(),
      ],
    );
  }

  // ---------------- MULTI-SELECT USER CHIPS ----------------

  Widget _userMultiSelectChips() {
    final users = ['All', 'Armaan', 'Waize', 'Sam'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final user = users[index];
          final isActive = selectedUsers.contains(user);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (user == 'All') {
                  selectedUsers
                    ..clear()
                    ..add('All');
                } else {
                  selectedUsers.remove('All');

                  if (isActive) {
                    selectedUsers.remove(user);
                  } else {
                    selectedUsers.add(user);
                  }

                  if (selectedUsers.isEmpty) {
                    selectedUsers.add('All');
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
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF6366F1)
                      : Colors.white.withOpacity(0.12),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                user,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
