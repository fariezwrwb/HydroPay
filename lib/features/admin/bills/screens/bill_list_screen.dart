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
  static const Color _white = Colors.white;
  static const Color _blue = Color(0xFF2563EB);
  static const Color _slate900 = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillController>().fetchAll();
    });
  }

  String _formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  void _showVerifyDialog(BillModel b) {
    if (b.payments == null) return;
    final paymentId = b.payments!.id;
    final ctrl = context.read<BillController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Verifikasi Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _infoRow('Pelanggan', b.customer?.name ?? 'Pelanggan #${b.customerId}'),
                  const SizedBox(height: 8),
                  _infoRow('Periode', b.periodLabel),
                  const SizedBox(height: 8),
                  _infoRow('Penggunaan', '${b.usageValue} m³'),
                  const SizedBox(height: 8),
                  _infoRow('Jumlah Bayar', _formatRupiah((b.payments?.totalAmount ?? b.price) as int)),
                  const SizedBox(height: 8),
                  _infoRow('Tanggal Bayar', b.payments?.paymentDate.toString() ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await ctrl.verifyRejected(paymentId);
                      if (mounted) _showSnack(ok ? 'Pembayaran ditolak' : ctrl.errorMessage ?? 'Gagal', ok ? const Color(0xFFEF4444) : const Color(0xFFEF4444));
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tolak', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await ctrl.verifyAccepted(paymentId);
                      if (mounted) _showSnack(ok ? 'Pembayaran diverifikasi' : ctrl.errorMessage ?? 'Gagal', ok ? const Color(0xFF10B981) : const Color(0xFFEF4444));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Terima', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF92400E))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF78350F))),
      ],
    );
  }

  Future<void> _confirmDelete(BillModel b) async {
    final ctrl = context.read<BillController>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        content: Text('Yakin hapus tagihan ${b.periodLabel} milik ${b.customer?.name ?? '-'}?', style: const TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await ctrl.delete(b.id);
      if (mounted) _showSnack(ok ? 'Tagihan berhasil dihapus' : ctrl.errorMessage ?? 'Gagal menghapus', ok ? const Color(0xFF10B981) : const Color(0xFFEF4444));
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BillController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ctrl.isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue))
                  : ctrl.errorMessage != null
                      ? _buildError(ctrl)
                      : RefreshIndicator(
                          onRefresh: () => ctrl.fetchAll(),
                          color: _blue,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatRow(ctrl),
                                const SizedBox(height: 24),
                                const Text('Daftar Tagihan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                                const SizedBox(height: 14),
                                if (ctrl.bills.isEmpty) _buildEmpty() else ...ctrl.bills.map((b) => _buildBillCard(b)),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const BillFormScreen()));
          if (result == true && mounted) ctrl.fetchAll();
        },
        backgroundColor: _blue,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: _white, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), _blue]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.water_drop, color: _white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('HydroPay', style: TextStyle(color: _slate900, fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminProfile),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.person_outline, color: _blue, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BillController ctrl) {
    return Row(
      children: [
        _statCard(label: 'Belum Bayar', value: '${ctrl.unpaidBills.length}', color: const Color(0xFFEF4444), icon: Icons.receipt_long),
        const SizedBox(width: 10),
        _statCard(label: 'Verifikasi', value: '${ctrl.pendingVerification.length}', color: const Color(0xFFF59E0B), icon: Icons.pending_actions),
        const SizedBox(width: 10),
        _statCard(label: 'Total', value: '${ctrl.totalCount}', color: _blue, icon: Icons.list_alt),
      ],
    );
  }

  Widget _statCard({required String label, required String value, required Color color, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(BillModel b) {
    final isPaid = b.paid;
    final isVerified = b.verifiedPayment ?? false;

    Color statusColor;
    String statusLabel;

    if (isPaid && isVerified) {
      statusColor = const Color(0xFF10B981);
      statusLabel = 'Lunas';
    } else if (b.hasPendingPayment) {
      statusColor = const Color(0xFFF59E0B);
      statusLabel = 'Menunggu';
    } else {
      statusColor = const Color(0xFFEF4444);
      statusLabel = 'Belum Bayar';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.calendar_month, color: _blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.customer?.name ?? 'Pelanggan #${b.customerId}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                      const SizedBox(height: 2),
                      Text(b.periodLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Row(
              children: [
                _chip(Icons.water_drop_outlined, '${b.usageValue} m³'),
                const SizedBox(width: 8),
                _chip(Icons.payments_outlined, _formatRupiah(b.price)),
                const SizedBox(width: 8),
                Flexible(child: _chip(Icons.numbers, b.measurementNumber, overflow: true)),
              ],
            ),
          ),
          if (b.hasPendingPayment)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Menunggu verifikasi pembayaran', style: TextStyle(fontSize: 12, color: Color(0xFF92400E)))),
                    TextButton(
                      onPressed: () => _showVerifyDialog(b),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        backgroundColor: const Color(0xFFFEF3C7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Verifikasi', style: TextStyle(fontSize: 12, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => BillFormScreen(bill: b)));
                      if (result == true && mounted) context.read<BillController>().fetchAll();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _confirmDelete(b),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, {bool overflow = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          overflow
              ? Flexible(child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF5A7A99)), overflow: TextOverflow.ellipsis))
              : Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF5A7A99))),
        ],
      ),
    );
  }

  Widget _buildError(BillController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 14),
            Text(ctrl.errorMessage ?? 'Terjadi kesalahan', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ctrl.fetchAll(),
              style: ElevatedButton.styleFrom(backgroundColor: _blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text('Belum ada tagihan', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Tekan tombol + untuk membuat tagihan baru', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, -4))]),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: BottomNavigationBar(
            currentIndex: 3,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: _blue,
            unselectedItemColor: const Color(0xFF9CA3AF),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            onTap: (i) {
              if (i == 3) return;
              switch (i) {
                case 0: Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard); break;
                case 1: Navigator.pushReplacementNamed(context, AppRoutes.adminServices); break;
                case 2: Navigator.pushReplacementNamed(context, AppRoutes.adminCustomers); break;
              }
            },
            items: [
              _navItem(Icons.home_outlined, Icons.home, 'Home'),
              _navItem(Icons.layers_outlined, Icons.layers, 'Layanan'),
              _navItem(Icons.people_outline, Icons.people, 'Customer'),
              _navItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Tagihan'),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(activeIcon),
      ),
    );
  }
}