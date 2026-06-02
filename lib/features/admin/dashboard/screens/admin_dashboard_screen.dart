import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../admin/profile/screen/admin_profile_screen.dart';
import '../../../../views/widget/admin_bottom_navbar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Color palette - Modern HydroPay Theme
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color secondaryGreen = Color(0xFF43A047);
  static const Color warningOrange = Color(0xFFFB8C00);
  static const Color dangerRed = Color(0xFFE53935);
  static const Color purpleAccent = Color(0xFF8E24AA);
  static const Color tealAccent = Color(0xFF00897B);
  
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color bgGrey = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
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
      backgroundColor: bgGrey,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ctrl.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ctrl.loadDashboard();
                        _fadeController.reset();
                        _fadeController.forward();
                      },
                      color: primaryBlue,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildWelcomeSection(ctrl),
                              const SizedBox(height: 24),
                              _buildStatCards(ctrl),
                              const SizedBox(height: 24),
                              _buildChartsSection(ctrl),
                              const SizedBox(height: 20),
                              _buildRecentActivities(ctrl),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryBlue, darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HydroPay',
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildHeaderIcon(Icons.notifications_none_rounded, primaryBlue, true),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryBlue, darkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: white,
                    fontSize: 14,
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

  Widget _buildHeaderIcon(IconData icon, Color color, bool hasBadge) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        if (hasBadge)
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: dangerRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWelcomeSection(AdminDashboardController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, darkBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Admin HydroPay',
                  style: TextStyle(
                    fontSize: 22,
                    color: white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${ctrl.totalBills} Total Bills Processed',
                    style: const TextStyle(
                      fontSize: 11,
                      color: white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(AdminDashboardController ctrl) {
    return Column(
      children: [
        // Row 1: Customer Count & Service Count
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Customers',
                value: '${ctrl.customerCount}',
                subtitle: 'Registered Users',
                icon: Icons.people_alt_rounded,
                gradient: const [Color(0xFF1E88E5), Color(0xFF1565C0)],
                iconBgColor: white,
                iconColor: primaryBlue,
                increaseText: '+12%',
                increaseColor: secondaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Active Services',
                value: '${ctrl.serviceCount}',
                subtitle: 'Available Plans',
                icon: Icons.build_circle_rounded,
                gradient: const [Color(0xFF43A047), Color(0xFF2E7D32)],
                iconBgColor: white,
                iconColor: secondaryGreen,
                increaseText: '+5%',
                increaseColor: secondaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 2: Unverified Payments & Verified Payments
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pending Verification',
                value: '${ctrl.unverifiedPaymentCount}',
                subtitle: 'Need Approval',
                icon: Icons.pending_actions_rounded,
                gradient: const [Color(0xFFFB8C00), Color(0xFFEF6C00)],
                iconBgColor: white,
                iconColor: warningOrange,
                increaseText: 'Action Required',
                increaseColor: warningOrange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Verified Payments',
                value: '${ctrl.verifiedPaymentCount}',
                subtitle: 'Successfully Verified',
                icon: Icons.verified_rounded,
                gradient: const [Color(0xFF00897B), Color(0xFF00695C)],
                iconBgColor: white,
                iconColor: tealAccent,
                increaseText: 'Completed',
                increaseColor: tealAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 3: Total Revenue & Outstanding
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Revenue',
                value: 'Rp ${ctrl.formatCurrency(ctrl.totalRevenue)}',
                subtitle: 'Collected Amount',
                icon: Icons.account_balance_wallet_rounded,
                gradient: const [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
                iconBgColor: white,
                iconColor: purpleAccent,
                increaseText: '+23%',
                increaseColor: secondaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Outstanding',
                value: 'Rp ${ctrl.formatCurrency(ctrl.outstandingAmount)}',
                subtitle: 'Due Amount',
                icon: Icons.warning_amber_rounded,
                gradient: const [Color(0xFFE53935), Color(0xFFC62828)],
                iconBgColor: white,
                iconColor: dangerRed,
                increaseText: 'Overdue',
                increaseColor: dangerRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required Color iconBgColor,
    required Color iconColor,
    required String increaseText,
    required Color increaseColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: white, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: increaseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  increaseText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: increaseColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textGrey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(AdminDashboardController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Payment Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  'Verification Rate',
                  ctrl.verifiedPaymentCount + ctrl.unverifiedPaymentCount > 0
                      ? (ctrl.verifiedPaymentCount / 
                          (ctrl.verifiedPaymentCount + ctrl.unverifiedPaymentCount) * 100)
                          .toStringAsFixed(0)
                      : '0',
                  'of payments verified',
                  primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'Collection Rate',
                  ctrl.totalRevenue + ctrl.outstandingAmount > 0
                      ? (ctrl.totalRevenue / 
                          (ctrl.totalRevenue + ctrl.outstandingAmount) * 100)
                          .toStringAsFixed(0)
                      : '0',
                  'of revenue collected',
                  secondaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentDistribution(ctrl),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, String percentage, String subtitle, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textGrey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: textLight,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: int.parse(percentage) / 100,
            backgroundColor: bgGrey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDistribution(AdminDashboardController ctrl) {
    final total = ctrl.verifiedPaymentCount + ctrl.unverifiedPaymentCount;
    final verifiedPercent = total > 0 ? (ctrl.verifiedPaymentCount / total * 100) : 0;
    final unverifiedPercent = total > 0 ? (ctrl.unverifiedPaymentCount / total * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: bgGrey, thickness: 1),
        const SizedBox(height: 16),
        const Text(
          'Payment Distribution',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDistributionItem(
                'Verified',
                '${verifiedPercent.toStringAsFixed(1)}%',
                ctrl.verifiedPaymentCount,
                secondaryGreen,
              ),
            ),
            Expanded(
              child: _buildDistributionItem(
                'Pending',
                '${unverifiedPercent.toStringAsFixed(1)}%',
                ctrl.unverifiedPaymentCount,
                warningOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: verifiedPercent.toInt(),
                child: Container(
                  height: 6,
                  color: secondaryGreen,
                ),
              ),
              Expanded(
                flex: unverifiedPercent.toInt(),
                child: Container(
                  height: 6,
                  color: warningOrange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionItem(String label, String percent, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textGrey,
          ),
        ),
        Text(
          percent,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          '($count)',
          style: const TextStyle(
            fontSize: 10,
            color: textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(AdminDashboardController ctrl) {
    final activities = [
      {
        'title': 'New Customer Registered',
        'time': '2 minutes ago',
        'icon': Icons.person_add_rounded,
        'color': primaryBlue,
      },
      {
        'title': 'Payment Verification Pending',
        'time': '15 minutes ago',
        'icon': Icons.pending_actions_rounded,
        'color': warningOrange,
      },
      {
        'title': 'Service Updated',
        'time': '1 hour ago',
        'icon': Icons.build_rounded,
        'color': secondaryGreen,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time_rounded, color: primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => _buildActivityItem(
            title: activity['title'] as String,
            time: activity['time'] as String,
            icon: activity['icon'] as IconData,
            color: activity['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textLight, size: 20),
        ],
      ),
    );
  }
}