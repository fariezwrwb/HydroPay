import 'package:aya_ikbal/features/customer/bills/screens/bill_confirm.dart';
import 'package:aya_ikbal/routes/app_routes.dart';
import 'package:aya_ikbal/views/widget/customer_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/payment_controller.dart';
import '../../../../core/constants/app_colors.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Belum Bayar', 'Lunas'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentController>().fetchAllBillsForHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PaymentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ctrl.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  _buildHeader(),
                  _buildFilterChips(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ctrl.fetchAllBillsForHistory(),
                      color: AppColors.primary,
                      child: _buildTransactionList(ctrl),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const CustomerBottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
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
              _iconButton(
                Icons.arrow_back_rounded,
                () => Navigator.pushReplacementNamed(context, AppRoutes.customerDashboard),
              ),
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

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Tagihan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(PaymentController ctrl) {
    List<Map<String, dynamic>> filtered =
        List.from(ctrl.transactions).cast<Map<String, dynamic>>();

    if (_selectedFilter == 'Belum Bayar') {
      filtered = filtered.where((t) => t['isPaid'] == false).toList();
    } else if (_selectedFilter == 'Lunas') {
      filtered = filtered.where((t) => t['isPaid'] == true).toList();
    }

    final grouped = _groupByMonth(filtered);

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: AppColors.divider),
            const SizedBox(height: 16),
            const Text(
              'Belum ada tagihan',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctrl.fetchAllBillsForHistory(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
        final transactions =
            (group['transactions'] as List).cast<Map<String, dynamic>>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                group['monthYear'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
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
                children: transactions.asMap().entries.map((entry) {
                  final isLast = entry.key == transactions.length - 1;
                  return Column(
                    children: [
                      _buildTransactionTile(entry.value, ctrl),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: 70,
                          endIndent: 16,
                          color: AppColors.divider,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction, PaymentController ctrl) {
    final isPaid = transaction['isPaid'] ?? false;
    final amount = transaction['amount'] ?? 0;
    final month = transaction['month'] ?? 1;
    final year = transaction['year'] ?? 2026;
    final title = transaction['title'] ?? 'PDAM Kota Kita';
    final billData = transaction['billData'];
    final period = '${_getMonthName(month)} $year';

    final statusColor = isPaid ? const Color(0xFF10B981) : AppColors.error;

    return InkWell(
      onTap: !isPaid && billData != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BillConfirmScreen(bill: billData)),
              )
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.water_drop_outlined,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Periode $period',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${ctrl.formatNumber(amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPaid ? 'Lunas' : 'Bayar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
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

  List<Map<String, dynamic>> _groupByMonth(List<Map<String, dynamic>> transactions) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var t in transactions) {
      final key = '${t['year']}-${t['month']}';
      grouped.putIfAbsent(key, () => []).add(t);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((key) {
      final parts = key.split('-');
      return {
        'monthYear': _getMonthYearName(int.parse(parts[1]), int.parse(parts[0])),
        'transactions': grouped[key]!,
      };
    }).toList();
  }

  String _getMonthYearName(int month, int year) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[month - 1]} $year';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}