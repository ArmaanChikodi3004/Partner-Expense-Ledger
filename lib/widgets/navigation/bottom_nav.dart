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
    return SizedBox(
      height: 88,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827).withOpacity(0.9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _navItem(Icons.home, 'Home', HomeTab.home),
                        _navItem(Icons.bar_chart, 'Reports', HomeTab.reports),
                      ],
                    ),
                  ),

                  const SizedBox(width: 56),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _navItem(Icons.folder, 'Attachments', HomeTab.attachments),
                        _navItem(Icons.settings, 'Settings', HomeTab.settings),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: -22,
            child: GestureDetector(
              onTap: onFabClick,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
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
            color: isActive ? const Color(0xFF6366F1) : Colors.white54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xFF6366F1) : Colors.white54,
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
