import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'package:aya_ikbal/features/admin/services/screens/service_list_screen.dart';
import 'package:aya_ikbal/features/admin/customers/screens/customer_list_screen.dart';
import 'package:aya_ikbal/features/admin/bills/screens/bill_list_screen.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import 'dart:math' as math;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNav = 0;
  String _selectedYear = '2024';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardController>().loadDashboard();
    });
  }

  void _onNavTap(int index) {
    setState(() => _selectedNav = index);
    switch (index) {
      case 1:
        Navigator.pushNamed(context, AppRoutes.adminCustomers);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.adminBills);
        break;
      case 3:
        // Analytics tetap di sini
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AdminDashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(ctrl),
            Expanded(
              child: ctrl.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ctrl.loadDashboard(),
                      color: const Color(0xFF2563EB),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildHeroCard(),
                            const SizedBox(height: 16),
                            _buildStatCards(ctrl),
                            const SizedBox(height: 16),
                            _buildMonthlyChart(),
                            const SizedBox(height: 16),
                            _buildPaymentMethods(),
                            const SizedBox(height: 16),
                            _buildZoneDistribution(ctrl),
                            const SizedBox(height: 16),
                            _buildBannerCard(
                              title: 'Our Infrastructure',
                              subtitle:
                                  'Managing the future of utility payments.',
                              color: const Color(0xFF1E3A5F),
                              icon: Icons.location_city_rounded,
                            ),
                            const SizedBox(height: 12),
                            _buildBannerCard(
                              title: 'Network Control',
                              subtitle: '24/7 Monitoring and AI prediction.',
                              color: const Color(0xFF0D2137),
                              icon: Icons.monitor_heart_rounded,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ─── TOP BAR ─────────────────────────────────────────────
  Widget _buildTopBar(AdminDashboardController ctrl) {
    return Container(
      color: const Color(0xFF1E2B3C),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'HydroPay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notif
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF1E2B3C), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Avatar
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminProfile),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO CARD ────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDEEAFB), Color(0xFFEEF5FD)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBDCEC), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Real-time water distribution and billing\ninsights across all zones.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF5A7A99),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STAT CARDS ───────────────────────────────────────────
  Widget _buildStatCards(AdminDashboardController ctrl) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                label: 'TOTAL REVENUE',
                value: '\$142.5k',
                subLabel: '+12.3%',
                subIcon: Icons.trending_up_rounded,
                subColor: const Color(0xFF22C55E),
                valueColor: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                label: 'ACTIVE METERS',
                value: '${ctrl.customerCount}',
                subLabel: '99.8% Online',
                subIcon: Icons.check_circle_outline_rounded,
                subColor: const Color(0xFF22C55E),
                valueColor: const Color(0xFF0D1B2A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                label: 'DAILY AVG',
                value: '4.2M Gal',
                subLabel: 'High Load',
                subIcon: Icons.warning_amber_rounded,
                subColor: const Color(0xFFF59E0B),
                valueColor: const Color(0xFF0D1B2A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                label: 'OUTSTANDING',
                value: '\$8.2k',
                subLabel: 'Due by 25th',
                subIcon: null,
                subColor: const Color(0xFF5A7A99),
                valueColor: const Color(0xFF0D1B2A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String subLabel,
    IconData? subIcon,
    required Color subColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (subIcon != null) ...[
                Icon(subIcon, size: 13, color: subColor),
                const SizedBox(width: 4),
              ],
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  color: subColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MONTHLY CHART ────────────────────────────────────────
  Widget _buildMonthlyChart() {
    final data2024 = [30.0, 45.0, 38.0, 72.0, 55.0, 40.0];
    final data2023 = [25.0, 38.0, 42.0, 58.0, 48.0, 35.0];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final data = _selectedYear == '2024' ? data2024 : data2023;
    const highlightIdx = 3; // Apr

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Monthly Water\nConsumption',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D1B2A),
                  height: 1.3,
                ),
              ),
              const Spacer(),
              _yearToggle('2023'),
              const SizedBox(width: 6),
              _yearToggle('2024'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final isHighlight = i == highlightIdx;
                final maxVal = data.reduce(math.max);
                final barHeight = (data[i] / maxVal) * 100;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: barHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isHighlight
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFCBDCEC),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        months[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isHighlight
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF94A3B8),
                          fontWeight: isHighlight
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _yearToggle(String year) {
    final isSelected = _selectedYear == year;
    return GestureDetector(
      onTap: () => setState(() => _selectedYear = year),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          year,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  // ─── PAYMENT METHODS (Donut Chart) ────────────────────────
  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _DonutChartPainter(
                  sections: [
                    _DonutSection(0.65, const Color(0xFF2563EB)),
                    _DonutSection(0.25, const Color(0xFF22C55E)),
                    _DonutSection(0.10, const Color(0xFF94A3B8)),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      Text(
                        'Covered',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFF2563EB), 'Card (65%)'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFF22C55E), 'Bank (25%)'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFF94A3B8), 'Cash (10%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF5A7A99)),
        ),
      ],
    );
  }

  // ─── ZONE DISTRIBUTION ────────────────────────────────────
  Widget _buildZoneDistribution(AdminDashboardController ctrl) {
    final zones = [
      {
        'name': 'Downtown North',
        'sub': '2.4k Connections • High Usage',
        'icon': Icons.location_city_rounded,
        'color': const Color(0xFFEFF6FF),
        'iconColor': const Color(0xFF2563EB),
      },
      {
        'name': 'South Suburbs',
        'sub': '1.8k Connections • Normal Usage',
        'icon': Icons.park_rounded,
        'color': const Color(0xFFF0FDF4),
        'iconColor': const Color(0xFF22C55E),
      },
      {
        'name': 'Industrial Park',
        'sub': '0.5k Connections • Critical Usage',
        'icon': Icons.factory_rounded,
        'color': const Color(0xFFF8FAFC),
        'iconColor': const Color(0xFF94A3B8),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Zone Distribution',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminCustomers),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...zones.map((z) => _zoneItem(z)).toList(),
        ],
      ),
    );
  }

  Widget _zoneItem(Map<String, dynamic> zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: zone['color'] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              zone['icon'] as IconData,
              color: zone['iconColor'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone['name'] as String,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  zone['sub'] as String,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCBDCEC),
            size: 20,
          ),
        ],
      ),
    );
  }

  // ─── BANNER CARDS ─────────────────────────────────────────
  Widget _buildBannerCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM NAV ───────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.people_rounded, 'label': 'Customers'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Bills'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Analytics'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = i == _selectedNav;
              return GestureDetector(
                onTap: () => _onNavTap(i),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 22,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFCBDCEC),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFCBDCEC),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── DONUT CHART PAINTER ──────────────────────────────────────
class _DonutSection {
  final double percent;
  final Color color;
  const _DonutSection(this.percent, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<_DonutSection> sections;
  const _DonutChartPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 6;
    const strokeWidth = 22.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const gapAngle = 0.04; // radians gap between sections
    double startAngle = -math.pi / 2;

    for (final s in sections) {
      final sweepAngle =
          (2 * math.pi * s.percent) - gapAngle;
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter old) => false;
}