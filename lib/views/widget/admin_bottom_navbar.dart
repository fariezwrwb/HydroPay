import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class AdminBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavbar({
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
                    AppRoutes.adminDashboard,
                  );
                  break;

                case 1:
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.adminServices,
                  );
                  break;

                case 2:
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.adminCustomers,
                  );
                  break;

                case 3:
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.adminBills,
                  );
                  break;
              }
            },
            items: [
              _buildItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: "Home",
              ),
              _buildItem(
                icon: Icons.layers_outlined,
                activeIcon: Icons.layers,
                label: "Layanan",
              ),
              _buildItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: "Customer",
              ),
              _buildItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: "Tagihan",
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