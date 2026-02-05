import 'package:flutter/material.dart';
import '../../screens/home/home_screen.dart';

class BottomNav extends StatelessWidget {
  final HomeTab activeTab;
  final Function(HomeTab) onTabChange;
  final VoidCallback onFabClick;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
    required this.onFabClick,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF111827).withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(Icons.home, 'Home', HomeTab.home),
              _navItem(Icons.bar_chart, 'Reports', HomeTab.reports),
              _navItem(Icons.settings, 'Settings', HomeTab.settings),

              // ➕ ADD BUTTON (RIGHT SIDE)
              GestureDetector(
                onTap: onFabClick,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF4F46E5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, HomeTab tab) {
    final isActive = activeTab == tab;

    return GestureDetector(
      onTap: () => onTabChange(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? const Color(0xFF6366F1)
                : Colors.white54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? const Color(0xFF6366F1)
                  : Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
