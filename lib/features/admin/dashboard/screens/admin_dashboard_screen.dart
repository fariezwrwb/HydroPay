import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../admin/profile/screen/admin_profile_screen.dart';
import '../../../../views/widget/admin_bottom_navbar.dart';
import 'dart:math' as math;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  String _selectedYear = '2024';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const _navy = Color(0xFF1E2B3C);
  static const _blue = Color(0xFF2563EB);
  static const _blueLight = Color(0xFFEFF6FF);
  static const _green = Color(0xFF22C55E);
  static const _greenLight = Color(0xFFF0FDF4);
  static const _amber = Color(0xFFF59E0B);
  static const _slate900 = Color(0xFF0D1B2A);
  static const _slate600 = Color(0xFF5A7A99);
  static const _slate400 = Color(0xFF94A3B8);
  static const _slate200 = Color(0xFFCBDCEC);
  static const _slate100 = Color(0xFFF1F5F9);
  static const _bgPage = Color(0xFFF0F4F8);
  static const _white = Colors.white;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardController>().loadDashboard();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AdminDashboardController>();

    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(ctrl),
            Expanded(
              child: ctrl.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _blue),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await ctrl.loadDashboard();
                          _fadeController.reset();
                          _fadeController.forward();
                        },
                        color: _blue,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildHeroCard(),
                              const SizedBox(height: 14),
                              _buildStatCards(ctrl),
                              const SizedBox(height: 14),
                              _buildMonthlyChart(),
                              const SizedBox(height: 14),
                              _buildPaymentMethods(),
                              const SizedBox(height: 14),
                              _buildZoneDistribution(ctrl),
                              const SizedBox(height: 14),
                              _buildBannerCard(
                                title: 'Our Infrastructure',
                                subtitle:
                                    'Managing the future of utility payments.',
                                colors: const [
                                  Color(0xFF1E3A5F),
                                  Color(0xFF0D2137),
                                ],
                                icon: Icons.location_city_rounded,
                                tag: 'NETWORK',
                              ),
                              const SizedBox(height: 10),
                              _buildBannerCard(
                                title: 'Network Control',
                                subtitle: '24/7 Monitoring and AI prediction.',
                                colors: const [
                                  Color(0xFF0D2137),
                                  Color(0xFF091929),
                                ],
                                icon: Icons.monitor_heart_rounded,
                                tag: 'AI',
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 0)
    );
  }

  Widget _buildTopBar(AdminDashboardController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), _blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _blue.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: _white,
              size: 17,
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            'HydroPay',
            style: TextStyle(
              color: _slate900,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: _slate400,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 7,
                top: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                    border: Border.all(color: _white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
         GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminProfileScreen(),
      ),
    );
  },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), _blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _blue.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: _white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDEEAFB), Color(0xFFEEF5FD)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBDCEC), width: 1),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ADMIN PANEL',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: _blue,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Analytics\nDashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _slate900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Real-time water distribution and billing insights across all zones.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _slate600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: _blue,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

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
                subColor: _green,
                valueColor: _blue,
                accentColor: _blueLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                label: 'ACTIVE METERS',
                value: '${ctrl.customerCount}',
                subLabel: '99.8% Online',
                subIcon: Icons.check_circle_outline_rounded,
                subColor: _green,
                valueColor: _slate900,
                accentColor: _greenLight,
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
                subColor: _amber,
                valueColor: _slate900,
                accentColor: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                label: 'OUTSTANDING',
                value: '\$8.2k',
                subLabel: 'Due by 25th',
                subIcon: Icons.calendar_today_rounded,
                subColor: _slate600,
                valueColor: _slate900,
                accentColor: _slate100,
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
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _slate400,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  subIcon ?? Icons.info_outline_rounded,
                  size: 14,
                  color: subColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: subColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  color: subColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final data2024 = [30.0, 45.0, 38.0, 72.0, 55.0, 40.0];
    final data2023 = [25.0, 38.0, 42.0, 58.0, 48.0, 35.0];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final data = _selectedYear == '2024' ? data2024 : data2023;
    const highlightIdx = 3;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Monthly Water',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _slate900,
                      ),
                    ),
                    Text(
                      'Consumption',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _slate900,
                      ),
                    ),
                  ],
                ),
              ),
              _yearToggle('2023'),
              const SizedBox(width: 6),
              _yearToggle('2024'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Peak: Apr $_selectedYear',
                style: const TextStyle(
                  fontSize: 11,
                  color: _blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
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
                      if (isHighlight)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: _blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${data[i].toInt()}',
                              style: const TextStyle(
                                color: _white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      Container(
                        height: barHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isHighlight ? _blue : _slate200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(7),
                          ),
                          boxShadow: isHighlight
                              ? [
                                  BoxShadow(
                                    color: _blue.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        months[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isHighlight ? _blue : _slate400,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _blue : _slate100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _blue.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          year,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? _white : _slate400,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      _PaymentItem('Card', 65, _blue, _blueLight),
      _PaymentItem('Bank Transfer', 25, _green, _greenLight),
      _PaymentItem('Cash', 10, _slate400, _slate100),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              fontWeight: FontWeight.w800,
              color: _slate900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 160,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    sections: [
                      _DonutSection(0.65, _blue),
                      _DonutSection(0.25, _green),
                      _DonutSection(0.10, _slate400),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _slate900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Covered',
                          style: TextStyle(
                            fontSize: 11,
                            color: _slate400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: methods.map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: m.bgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${m.percent}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: m.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: _slate900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: m.percent / 100,
                                    backgroundColor: m.bgColor,
                                    valueColor:
                                        AlwaysStoppedAnimation(m.color),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneDistribution(AdminDashboardController ctrl) {
    final zones = [
      _ZoneItem(
        name: 'Downtown North',
        sub: '2.4k Connections',
        tag: 'High Usage',
        tagColor: const Color(0xFFEFF6FF),
        tagTextColor: _blue,
        icon: Icons.location_city_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: _blue,
      ),
      _ZoneItem(
        name: 'South Suburbs',
        sub: '1.8k Connections',
        tag: 'Normal',
        tagColor: const Color(0xFFF0FDF4),
        tagTextColor: _green,
        icon: Icons.park_rounded,
        iconBg: const Color(0xFFF0FDF4),
        iconColor: _green,
      ),
      _ZoneItem(
        name: 'Industrial Park',
        sub: '0.5k Connections',
        tag: 'Critical',
        tagColor: const Color(0xFFFFF1F2),
        tagTextColor: const Color(0xFFEF4444),
        icon: Icons.factory_rounded,
        iconBg: const Color(0xFFFFF1F2),
        iconColor: const Color(0xFFEF4444),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  fontWeight: FontWeight.w800,
                  color: _slate900,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminCustomers),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _blueLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      color: _blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...zones.map((z) => _zoneItem(z)),
        ],
      ),
    );
  }

  Widget _zoneItem(_ZoneItem zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgPage,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: zone.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(zone.icon, color: zone.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  zone.sub,
                  style: const TextStyle(fontSize: 11.5, color: _slate400),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: zone.tagColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              zone.tag,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: zone.tagTextColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: _slate200, size: 20),
        ],
      ),
    );
  }

  Widget _buildBannerCard({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required IconData icon,
    required String tag,
  }) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -35,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _white.withOpacity(0.9), size: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 9,
                      color: _white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentItem {
  final String name;
  final int percent;
  final Color color;
  final Color bgColor;
  const _PaymentItem(this.name, this.percent, this.color, this.bgColor);
}

class _ZoneItem {
  final String name, sub, tag;
  final Color tagColor, tagTextColor, iconColor;
  final Color iconBg;
  final IconData icon;
  const _ZoneItem({
    required this.name,
    required this.sub,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

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
    final radius = math.min(cx, cy) - 8;
    const strokeWidth = 20.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const gapAngle = 0.05;
    double startAngle = -math.pi / 2;

    for (final s in sections) {
      final sweepAngle = (2 * math.pi * s.percent) - gapAngle;
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