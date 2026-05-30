import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_dashboard_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../views/widget/customer_bottom_navbar.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerDashboardController>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CustomerDashboardController>();
    final name = ctrl.profile?['name'] ?? 'Pelanggan';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: ctrl.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF007AFF)))
            : RefreshIndicator(
                color: const Color(0xFF007AFF),
                onRefresh: ctrl.fetchDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTopBar(name),
                      _buildBalanceCard(ctrl),
                      _buildMenuGrid(),
                      _buildBillSection(ctrl),
                      _buildBottomCards(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const CustomerBottomNavbar(currentIndex: 0),
    );
  }


  Widget _buildTopBar(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Halo, Selamat Datang',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
          ),
          // Logo
          Row(
            children: [
              const Icon(Icons.water_drop, color: Color(0xFF007AFF), size: 20),
              const SizedBox(width: 4),
              const Text(
                'HydroPay',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Notif & Settings
          _iconBtn(Icons.notifications_outlined, () {}),
          const SizedBox(width: 8),
          _iconBtn(Icons.settings_outlined, () {}),
        ],
      ),
    );
  }


  Widget _buildBalanceCard(CustomerDashboardController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL SALDO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Rp ${ctrl.unpaidCount > 0 ? '${ctrl.unpaidCount} tagihan belum bayar' : '0 tagihan'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _cardButton(
                    icon: Icons.add_circle_outline,
                    label: 'Bayar',
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.customerBills),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _cardButton(
                    icon: Icons.send_outlined,
                    label: 'Riwayat',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menus = [
      {'icon': Icons.home_outlined, 'label': 'Bayar PDAM'},
      {'icon': Icons.account_balance_outlined, 'label': 'Top Up'},
      {'icon': Icons.receipt_long_outlined, 'label': 'Tagihan Lain'},
      {'icon': Icons.send_outlined, 'label': 'Transfer'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: menus.map((m) {
          return GestureDetector(
            onTap: m['label'] == 'Bayar PDAM'
                ? () => Navigator.pushNamed(context, AppRoutes.customerBills)
                : null,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(m['icon'] as IconData,
                      color: const Color(0xFF007AFF), size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  m['label'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBillSection(CustomerDashboardController ctrl) {
    final unpaidBills =
        ctrl.bills.where((b) => b['paid'] == false).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tagihan Tederkat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.customerBills),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (unpaidBills.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Tidak ada tagihan yang belum dibayar',
                  style: TextStyle(color: Color(0xFF8E8E93)),
                ),
              ),
            )
          else
            ...unpaidBills.take(2).map((bill) => _buildBillCard(bill)),
        ],
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final month = bill['month'] ?? 0;
    final year = bill['year'] ?? 0;
    final price = bill['price'] ?? 0;
    final monthName = month >= 1 && month <= 12 ? months[month] : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month,
                    color: Color(0xFFE53935), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PDAM Kota Kita',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    Text(
                      'Periode: $monthName $year',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp $price',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'BELUM BAYAR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 14, color: Color(0xFF8E8E93)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Gunakan Promo Hemat PDAM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.customerBills),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Bayar Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    
  }


  Widget _buildBottomCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop_outlined,
                        color: Color(0xFF34C759), size: 28),
                    SizedBox(height: 6),
                    Text(
                      'Pemakaian air',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF34C759),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_down,
                        color: Color(0xFF9C27B0), size: 28),
                    SizedBox(height: 6),
                    Text(
                      'Penghematan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C27B0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
     
    );
  }

 
  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF007AFF), size: 18),
      ),
      
    );
    
  }
}