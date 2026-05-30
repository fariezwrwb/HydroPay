import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_controller.dart';
import '../models/customer_model.dart';
import '../screens/customer_form_screen.dart';
import '../../../../routes/app_routes.dart';
import '../../../../views/widget/admin_bottom_navbar.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
// Customers aktif

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerController>().fetchAll();
    });
  }

  

  Future<void> _confirmDelete(BuildContext context, CustomerModel c) async {
    final ctrl = context.read<CustomerController>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Tolak / Hapus Customer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text('Yakin ingin menghapus ${c.name}?'),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tolak',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ctrl.delete(c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '${c.name} berhasil dihapus'
                : ctrl.errorMessage ?? 'Gagal menghapus'),
            backgroundColor:
                success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showApproveDialog(BuildContext context, CustomerModel c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Setujui Customer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${c.name}'),
            const SizedBox(height: 4),
            Text('No. Pelanggan: ${c.customerNumber}'),
            const SizedBox(height: 4),
            Text('Layanan: ${c.service?.name ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customer disetujui'),
                  backgroundColor: Color(0xFF2563EB),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Setujui',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CustomerController>();

    // Hitung stat
    final totalWaiting = ctrl.customers.length;
    final now = DateTime.now();
    final todayCount = ctrl.customers.where((c) {
      try {
        final d = DateTime.parse(c.createdAt);
        return d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
      } catch (_) {
        return false;
      }
    }).length;

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
                        color: Color(0xFF2563EB),
                      ),
                    )
                  : ctrl.errorMessage != null
                      ? _buildError(ctrl)
                      : RefreshIndicator(
                          onRefresh: () => ctrl.fetchAll(),
                          color: const Color(0xFF2563EB),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stat row
                                _buildStatRow(totalWaiting, todayCount),
                                const SizedBox(height: 20),

                                // Customer cards
                                if (ctrl.customers.isEmpty)
                                  _buildEmpty()
                                else
                                  ...ctrl.customers.asMap().entries.map(
                                        (e) => _buildCustomerCard(
                                          context,
                                          e.value,
                                          isNew: e.key == 0,
                                        ),
                                      ),

                                const SizedBox(height: 16),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CustomerFormScreen()),
          );
          if (result == true && mounted) {
            ctrl.fetchAll();
          }
        },
        backgroundColor: const Color(0xFF2563EB),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      bottomNavigationBar: const AdminBottomNavbar(
  currentIndex: 2,
),
    );
    
  }

  // ─── TOP BAR ──────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFF1E2B3C),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
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
              const SizedBox(width: 10),
              const Text(
                ' fikasi Pelanggan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminProfile),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
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

  // ─── STAT ROW ─────────────────────────────────────────────
  Widget _buildStatRow(int waiting, int today) {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            label: 'Menunggu',
            value: waiting.toString().padLeft(2, '0'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statBox(
            label: 'Hari Ini',
            value: today.toString().padLeft(2, '0'),
          ),
        ),
      ],
    );
  }

  Widget _statBox({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B2A),
            height: 1.1,
          ),
        ),
      ],
    );
  }

  // ─── CUSTOMER CARD ────────────────────────────────────────
  Widget _buildCustomerCard(
    BuildContext context,
    CustomerModel c, {
    bool isNew = false,
  }) {
    // Format tanggal
    String formattedDate = '-';
    try {
      final d = DateTime.parse(c.createdAt).toLocal();
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final h = d.hour.toString().padLeft(2, '0');
      final m = d.minute.toString().padLeft(2, '0');
      formattedDate =
          'Diajukan: ${d.day} ${months[d.month]} ${d.year}, $h:$m';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header nama + badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNew
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isNew
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFF59E0B),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isNew ? 'Baru' : 'Menunggu',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isNew
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // KTP Photo Placeholder
          Container(
            height: 130,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomPaint(
                      painter: _KTPPatternPainter(),
                    ),
                  ),
                ),
                // KTP icon overlay
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBDCEC),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 32,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Foto KTP',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Info tambahan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.numbers_rounded,
                    size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  c.customerNumber,
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.water_drop_outlined,
                    size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  c.service?.name ?? 'Layanan -',
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Action buttons
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Tolak
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, c),
                    icon: const Icon(Icons.close_rounded,
                        size: 15, color: Color(0xFFEF4444)),
                    label: const Text(
                      'Tolak',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Setujui
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(context, c),
                    icon: const Icon(Icons.check_rounded,
                        size: 15, color: Colors.white),
                    label: const Text(
                      'Setujui',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ERROR ────────────────────────────────────────────────
  Widget _buildError(CustomerController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(
            ctrl.errorMessage ?? 'Terjadi kesalahan',
            style: const TextStyle(color: Color(0xFF5A7A99)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ctrl.fetchAll(),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB)),
            child: const Text('Coba Lagi',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY ────────────────────────────────────────────────
  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded,
                size: 56, color: Color(0xFFCBDCEC)),
            SizedBox(height: 12),
            Text(
              'Belum ada data pelanggan',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  
}

// ─── KTP PATTERN PAINTER ──────────────────────────────────────
class _KTPPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    // Subtle diagonal lines untuk efek background KTP
    final linePaint = Paint()
      ..color = const Color(0xFFE8EFF5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width + size.height; i += 18) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }

    // Corner accent
    final accentPaint = Paint()
      ..color = const Color(0xFFCBDCEC)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, 40, 4),
        const Radius.circular(2),
      ),
      accentPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, 4, 40),
        const Radius.circular(2),
      ),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}