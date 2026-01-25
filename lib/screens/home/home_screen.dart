import 'package:flutter/material.dart';
import '../../widgets/navigation/bottom_nav.dart';
import '../../widgets/balance/balance_card.dart';
import '../../widgets/cards/category_chart_card.dart';
import '../../widgets/transactions/transaction_list.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/entry/add_entry_sheet.dart';

enum HomeTab { home, reports, settings }

// ✅ Date Filter Enum
enum DateFilter {
  today,
  last2Days,
  last7Days,
  last15Days,
  lastMonth,
  custom,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab activeTab = HomeTab.home;

  // User filter
  String selectedUser = 'All';

  // Date filter
  DateFilter activeDateFilter = DateFilter.last7Days;
  DateTimeRange? customRange;

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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.sync, color: Colors.white70),
          )
        ],
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

              const SizedBox(height: 16),

              // ✅ USER FILTER CHIPS
              _userFilterChips(),

              const SizedBox(height: 12),

              // ✅ DATE FILTER CHIPS
              _dateFilterChips(),

              const SizedBox(height: 16),

              // Category chart (later: filter by user + date)
              const CategoryChartCard(),

              const SizedBox(height: 20),

              const TransactionList(),

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

  // ---------------- USER FILTER CHIPS ----------------

  Widget _userFilterChips() {
    final users = ['All', 'Armaan', 'Waize', 'Sam'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final user = users[index];
          final isActive = selectedUser == user;

          return GestureDetector(
            onTap: () => setState(() => selectedUser = user),
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

  // ---------------- DATE FILTER CHIPS ----------------

  Widget _dateFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DateFilter.values.map((filter) {
        final isActive = activeDateFilter == filter;

        return ChoiceChip(
  label: Text(_labelForFilter(filter)),
  selected: isActive,
  onSelected: (_) async {
    if (filter == DateFilter.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (range != null) {
        setState(() {
          customRange = range;
          activeDateFilter = filter;
        });
      }
    } else {
      setState(() => activeDateFilter = filter);
    }
  },

  // ✅ FORCE DARK MODE COLORS
  backgroundColor: const Color(0xFF1F2937), // dark gray
  selectedColor: const Color(0xFF6366F1),   // accent blue

  disabledColor: const Color(0xFF1F2937),

  labelStyle: TextStyle(
    color: isActive ? Colors.white : Colors.white70,
    fontWeight: FontWeight.w600,
    fontSize: 12,
  ),

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: isActive
          ? const Color(0xFF6366F1)
          : Colors.white.withOpacity(0.15),
    ),
  ),
);

      }).toList(),
    );
  }

  // ---------------- DATE FILTER LABEL ----------------

  String _labelForFilter(DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.last2Days:
        return '2 Days';
      case DateFilter.last7Days:
        return '7 Days';
      case DateFilter.last15Days:
        return '15 Days';
      case DateFilter.lastMonth:
        return '1 Month';
      case DateFilter.custom:
        return 'Custom';
    }
  }
}
