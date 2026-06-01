import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/bill_controller.dart';
import '../models/bill_model.dart';
import '../screens/bill_form_screen.dart';
import '../../../../routes/app_routes.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillController>().fetchAll();
    });
  }

  String _formatRupiah(int price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  // ─── VERIFY DIALOG ────────────────────────────────────────
  void _showVerifyDialog(BillModel b) {
    if (b.payments == null) return;
    final paymentId = b.payments!.id;
    final ctrl = context.read<BillController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBDCEC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Verifikasi Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B2A),
              ),
            ),
            const SizedBox(height: 12),
            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Pelanggan',
                      b.customer?.name ?? 'Pelanggan #${b.customerId}'),
                  const SizedBox(height: 4),
                  _infoRow('Periode', b.periodLabel),
                  const SizedBox(height: 4),
                  _infoRow('Penggunaan', '${b.usageValue} m³'),
                  const SizedBox(height: 4),
                  _infoRow(
                    'Jumlah Bayar',
                    _formatRupiah(
                        b.payments?.totalAmount ?? b.price),
                  ),
                  const SizedBox(height: 4),
                  _infoRow('Tanggal Bayar',
                      b.payments?.paymentDate ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok =
                          await ctrl.verifyRejected(paymentId);
                      if (mounted) {
                        _showSnack(
                          ok
                              ? 'Pembayaran ditolak'
                              : ctrl.errorMessage ?? 'Gagal',
                          ok
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFEF4444),
                        );
                      }
                    },
                    icon: const Icon(Icons.close_rounded,
                        size: 15, color: Color(0xFFEF4444)),
                    label: const Text('Tolak',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok =
                          await ctrl.verifyAccepted(paymentId);
                      if (mounted) {
                        _showSnack(
                          ok
                              ? 'Pembayaran diverifikasi'
                              : ctrl.errorMessage ?? 'Gagal',
                          ok
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded,
                        size: 15, color: Colors.white),
                    label: const Text('Terima',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
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

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF92400E))),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF78350F))),
      ],
    );
  }

  // ─── CONFIRM DELETE ───────────────────────────────────────
  Future<void> _confirmDelete(BillModel b) async {
    final ctrl = context.read<BillController>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tagihan',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
            'Yakin hapus tagihan ${b.periodLabel} milik ${b.customer?.name ?? '-'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await ctrl.delete(b.id);
      if (mounted) {
        _showSnack(
          ok
              ? 'Tagihan berhasil dihapus'
              : ctrl.errorMessage ?? 'Gagal menghapus',
          ok
              ? const Color(0xFF22C55E)
              : const Color(0xFFEF4444),
        );
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BillController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ctrl.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2563EB)))
                  : ctrl.errorMessage != null
                      ? _buildError(ctrl)
                      : RefreshIndicator(
                          onRefresh: () => ctrl.fetchAll(),
                          color: const Color(0xFF2563EB),
                          child: SingleChildScrollView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                                16, 16, 16, 100),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _buildStatRow(ctrl),
                                const SizedBox(height: 20),
                                const Text(
                                  'Daftar Tagihan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (ctrl.bills.isEmpty)
                                  _buildEmpty()
                                else
                                  ...ctrl.bills.map(
                                      (b) => _buildBillCard(b)),
                              ],
                            ),
                          ),
                        ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const BillFormScreen()),
          );
          if (result == true && mounted) {
            ctrl.fetchAll();
          }
        },
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFF1E2B3C),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.water_drop_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Text(
            'Kelola Tagihan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminProfile),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2563EB),
              child: Text('AD',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STAT ROW ─────────────────────────────────────────────
  Widget _buildStatRow(BillController ctrl) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'BELUM BAYAR',
            value: '${ctrl.unpaidBills.length}',
            color: const Color(0xFFEF4444),
            bg: const Color(0xFFFFF1F2),
            icon: Icons.receipt_long_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            label: 'VERIFIKASI',
            value: '${ctrl.pendingVerification.length}',
            color: const Color(0xFFF59E0B),
            bg: const Color(0xFFFFFBEB),
            icon: Icons.pending_actions_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            label: 'TOTAL',
            value: '${ctrl.totalCount}',
            color: const Color(0xFF2563EB),
            bg: const Color(0xFFEFF6FF),
            icon: Icons.list_alt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 45, 48, 53),
                  letterSpacing: .3)),
        ],
      ),
    );
  }

  // ─── BILL CARD ────────────────────────────────────────────
  Widget _buildBillCard(BillModel b) {
    final isPaid = b.paid;
    final isVerified = b.verifiedPayment ?? false;

    Color statusColor;
    String statusLabel;
    Color statusBg;

    if (isPaid && isVerified) {
      statusColor = const Color(0xFF22C55E);
      statusBg = const Color(0xFFF0FDF4);
      statusLabel = 'Lunas';
    } else if (b.hasPendingPayment) {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0xFFFFFBEB);
      statusLabel = 'Menunggu Verifikasi';
    } else {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFFF1F2);
      statusLabel = 'Belum Bayar';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month_rounded,
                      color: Color(0xFF2563EB), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.customer?.name ??
                            'Pelanggan #${b.customerId}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1B2A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(b.periodLabel,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ],
            ),
          ),

          // Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Row(
              children: [
                _chip(Icons.bolt_rounded,
                    '${b.usageValue} m³'),
                const SizedBox(width: 6),
                _chip(Icons.payments_rounded,
                    _formatRupiah(b.price)),
                const SizedBox(width: 6),
                Flexible(
                  child: _chip(Icons.tag_rounded,
                      b.measurementNumber,
                      overflow: true),
                ),
              ],
            ),
          ),

          // Pending payment box
          if (b.hasPendingPayment)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFF59E0B)
                          .withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time_rounded,
                            size: 13, color: Color(0xFFB45309)),
                        SizedBox(width: 4),
                        Text('Menunggu verifikasi pembayaran',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB45309))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showVerifyDialog(b),
                            icon: const Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: Color(0xFFEF4444)),
                            label: const Text('Tolak',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFEF4444),
                                    fontWeight:
                                        FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFFEF4444)),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(7)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showVerifyDialog(b),
                            icon: const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white),
                            label: const Text('Terima',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF22C55E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(7)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BillFormScreen(bill: b),
                        ),
                      );
                      if (result == true && mounted) {
                        context
                            .read<BillController>()
                            .fetchAll();
                      }
                    },
                    icon: const Icon(Icons.edit_rounded,
                        size: 13, color: Color(0xFF2563EB)),
                    label: const Text('Edit',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDelete(b),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFFFCDD2)),
                    ),
                    child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label,
      {bool overflow = false}) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 3),
        overflow
            ? Flexible(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF5A7A99)),
                    overflow: TextOverflow.ellipsis))
            : Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF5A7A99))),
      ],
    );
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: content,
    );
  }

  // ─── ERROR & EMPTY ────────────────────────────────────────
  Widget _buildError(BillController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(ctrl.errorMessage ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctrl.fetchAll(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0),
              child: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 56, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text('Belum ada tagihan',
                style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Tap + untuk membuat tagihan baru',
                style: TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ───────────────────────────────────────────
  Widget _buildBottomNav() {
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
        top: false,
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            currentIndex: 3,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFF8F9FA),
            elevation: 0,
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: const Color(0xFF8E8E93),
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle:
                const TextStyle(fontSize: 11),
            onTap: (i) {
              if (i == 3) return;
              switch (i) {
                case 0:
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.adminDashboard);
                  break;
                case 1:
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.adminServices);
                  break;
                case 2:
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.adminCustomers);
                  break;
              }
            },
            items: [
              _navItem(
                  Icons.home_outlined, Icons.home, 'Home'),
              _navItem(Icons.layers_outlined, Icons.layers,
                  'Layanan'),
              _navItem(Icons.people_outline, Icons.people,
                  'Customer'),
              _navItem(Icons.receipt_long_outlined,
                  Icons.receipt_long, 'Tagihan'),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(
      IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(activeIcon),
      ),
    );
  }
}