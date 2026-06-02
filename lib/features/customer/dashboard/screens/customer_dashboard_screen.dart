import 'package:aya_ikbal/features/customer/bills/screens/bill_confirm.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_dashboard_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../views/widget/customer_bottom_navbar.dart';
import '../../../../core/constants/app_colors.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartAnimCtrl;
  late Animation<double> _chartFadeAnim;
  int? _touchedBarIndex;

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _chartAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _chartFadeAnim = CurvedAnimation(parent: _chartAnimCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerDashboardController>().fetchDashboardData();
      _chartAnimCtrl.forward();
    });
  }

  @override
  void dispose() {
    _chartAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CustomerDashboardController>();
    final name = ctrl.profile?['name'] ?? 'Customer';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ctrl.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ctrl.fetchDashboardData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(name),
                      const SizedBox(height: 20),
                      _buildBalanceCard(ctrl),
                      const SizedBox(height: 24),
                      _buildServiceMenu(),
                      const SizedBox(height: 24),
                      _buildBillChart(ctrl),
                      const SizedBox(height: 24),
                      _buildBillSection(ctrl),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const CustomerBottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: AppColors.primary, size: 26),
              const SizedBox(width: 6),
              const Text(
                'HydroPay',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _iconButton(Icons.notifications_outlined, () {}),
              const SizedBox(width: 8),
              _iconButton(Icons.settings_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.customerProfile)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  
  Widget _buildBalanceCard(CustomerDashboardController ctrl) {
    final totalUnpaid = ctrl.totalUnpaidAmount;
    final unpaidCount = ctrl.unpaidCount;
    final name = ctrl.profile?['name'] ?? 'Customer';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $name 👋',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Berikut tagihan aktif Anda',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text(
              'TOTAL TAGIHAN',
              style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.2),
            ),
            const SizedBox(height: 6),
            Text(
              'Rp ${_formatNumber(totalUnpaid)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unpaidCount Tagihan Belum Dibayar',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _cardActionButton(
                    icon: Icons.payment_rounded,
                    label: 'Bayar Sekarang',
                    isPrimary: true,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.customerBills),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _cardActionButton(
                    icon: Icons.history_rounded,
                    label: 'Riwayat',
                    isPrimary: false,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.customerBills),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? AppColors.primary : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildServiceMenu() {
    final menus = [
      {'icon': Icons.water_drop_outlined, 'label': 'PDAM', 'color': AppColors.primary},
      {'icon': Icons.bolt_outlined, 'label': 'Listrik', 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.signal_cellular_alt, 'label': 'Pulsa', 'color': const Color(0xFF10B981)},
      {'icon': Icons.tv_outlined, 'label': 'TV Kabel', 'color': AppColors.tertiary},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Layanan Kami'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: menus.map((menu) {
                final color = menu['color'] as Color;
                return GestureDetector(
                  onTap: menu['label'] == 'PDAM'
                      ? () => Navigator.pushNamed(context, AppRoutes.customerBills)
                      : null,
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(menu['icon'] as IconData, color: color, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        menu['label'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
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
    );
  }


  Widget _buildBillChart(CustomerDashboardController ctrl) {
    final summary = _getMonthlySummary(ctrl.bills);
    if (summary.isEmpty) return const SizedBox.shrink();

    final maxVal = summary.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    final avgVal = summary.fold(0, (s, e) => s + e.total) ~/ summary.length;
    final totalUnpaid = summary.fold(0, (s, e) => s + e.unpaid);
    final interval = _niceInterval(maxVal.toDouble());

    return FadeTransition(
      opacity: _chartFadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Tren Tagihan'),
                Row(
                  children: [
                    _chartLegend(AppColors.primary, 'Total'),
                    const SizedBox(width: 12),
                    _chartLegend(AppColors.error, 'Belum Bayar'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card
            Container(
              padding: const EdgeInsets.fromLTRB(12, 20, 16, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
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
                children: [
                  // Bar Chart
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxVal.toDouble() * 1.25,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 10,
                            getTooltipColor: (_) => AppColors.primary.withOpacity(0.9),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final item = summary[group.x];
                              final label = rodIndex == 0 ? 'Total' : 'Belum Bayar';
                              final val = rod.toY.toInt();
                              if (val == 0) return null;
                              return BarTooltipItem(
                                '$label\nRp ${_formatNumber(val)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          touchCallback: (event, response) {
                            setState(() {
                              _touchedBarIndex =
                                  response?.spot?.touchedBarGroupIndex;
                            });
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final i = val.toInt();
                                if (i < 0 || i >= summary.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _months[summary[i].month],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: _touchedBarIndex == i
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 46,
                              interval: interval,
                              getTitlesWidget: (val, meta) => Text(
                                _shortFormat(val.toInt()),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: interval,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.black.withOpacity(0.06),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(summary.length, (i) {
                          final item = summary[i];
                          final isTouched = _touchedBarIndex == i;
                          return BarChartGroupData(
                            x: i,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(
                                toY: item.total.toDouble(),
                                width: 14,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isTouched
                                      ? [AppColors.primary, const Color(0xFF60A5FA)]
                                      : [
                                          AppColors.primary.withOpacity(0.75),
                                          AppColors.primary.withOpacity(0.45),
                                        ],
                                ),
                              ),
                              BarChartRodData(
                                toY: item.unpaid.toDouble(),
                                width: 14,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isTouched
                                      ? [AppColors.error, const Color(0xFFFCA5A5)]
                                      : [
                                          AppColors.error.withOpacity(0.75),
                                          AppColors.error.withOpacity(0.4),
                                        ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                   
                    ),
                  ),

                  // Divider + Summary chips
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _chartSummaryChip(
                          label: 'Rata-rata/Bulan',
                          value: _formatNumber(avgVal),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _chartSummaryChip(
                          label: 'Tertinggi',
                          value: _formatNumber(maxVal),
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _chartSummaryChip(
                          label: 'Belum Bayar',
                          value: _formatNumber(totalUnpaid),
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _chartSummaryChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            'Rp $value',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Aggregate bills → per-month summary, 6 bulan terakhir
  List<_MonthSummary> _getMonthlySummary(List<Map<String, dynamic>> bills) {
    final Map<String, _MonthSummary> map = {};
    for (final bill in bills) {
      final month = bill['month'] as int? ?? 0;
      final year = bill['year'] as int? ?? 0;
      final price = bill['price'] as int? ?? 0;
      final paid = bill['paid'] as bool? ?? false;
      final key = '$year-${month.toString().padLeft(2, '0')}';

      if (map.containsKey(key)) {
        map[key] = _MonthSummary(
          month: month,
          year: year,
          total: map[key]!.total + price,
          unpaid: map[key]!.unpaid + (paid ? 0 : price),
        );
      } else {
        map[key] = _MonthSummary(
          month: month,
          year: year,
          total: price,
          unpaid: paid ? 0 : price,
        );
      }
    }

    final sorted = map.values.toList()
      ..sort((a, b) {
        final c = a.year.compareTo(b.year);
        return c != 0 ? c : a.month.compareTo(b.month);
      });

    return sorted.length > 6 ? sorted.sublist(sorted.length - 6) : sorted;
  }

  // ── Bill Section ──────────────────────────────────────────────────────────
  Widget _buildBillSection(CustomerDashboardController ctrl) {
    final unpaidBills = ctrl.bills.where((b) => b['paid'] == false).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Tagihan Belum Dibayar'),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.customerBills),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (unpaidBills.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 48, color: Color(0xFF10B981)),
                    SizedBox(height: 12),
                    Text(
                      'Semua Tagihan Lunas!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tidak ada tagihan yang perlu dibayar',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
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
                children: unpaidBills.take(3).toList().asMap().entries.map((entry) {
                  final isLast = entry.key == (unpaidBills.take(3).length - 1);
                  return Column(
                    children: [
                      _buildBillTile(entry.value),
                      if (!isLast)
                        const Divider(
                            height: 1,
                            indent: 70,
                            endIndent: 16,
                            color: AppColors.divider),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillTile(Map<String, dynamic> bill) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final month = bill['month'] ?? 0;
    final year = bill['year'] ?? 0;
    final price = bill['price'] ?? 0;
    final serviceName = bill['service']?['name'] ?? 'PDAM Kota Kita';
    final monthName = month >= 1 && month <= 12 ? months[month] : '-';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BillConfirmScreen(bill: bill)),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.water_drop_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Periode $monthName $year',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${_formatNumber(price)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Bayar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  String _formatNumber(int number) {
    String str = number.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return result;
  }

  String _shortFormat(int val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}jt';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}rb';
    return val.toString();
  }

  double _niceInterval(double max) {
    if (max <= 0) return 50000;
    final raw = max / 4;
    final magnitude = raw.toString().split('.')[0].length - 1;
    final factor = _pow10(magnitude);
    return ((raw / factor).ceil() * factor).toDouble();
  }

  double _pow10(int exp) {
    double r = 1;
    for (int i = 0; i < exp; i++) r *= 10;
    return r;
  }
}

// ── Internal data model ───────────────────────────────────────────────────
class _MonthSummary {
  final int month;
  final int year;
  final int total;
  final int unpaid;

  const _MonthSummary({
    required this.month,
    required this.year,
    required this.total,
    required this.unpaid,
  });
}