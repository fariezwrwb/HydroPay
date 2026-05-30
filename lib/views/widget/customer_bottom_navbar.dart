import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class CustomerBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const CustomerBottomNavbar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFF8F9FA),
            elevation: 0,
            selectedItemColor: const Color(0xFF007AFF),
            unselectedItemColor: const Color(0xFF8E8E93),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
            onTap: (i) {
              if (i == currentIndex) return;

              switch (i) {
                case 0:
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.customerDashboard,
                  );
                  break;

                case 1:
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.customerBills,
                  );
                  break;

                case 2:
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.customerProfile,
                  );
                  break;
              }
            },
            items: [
              _buildItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
              ),
              _buildItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
              ),
              _buildItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF).withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(activeIcon),
      ),
    );
  }
}