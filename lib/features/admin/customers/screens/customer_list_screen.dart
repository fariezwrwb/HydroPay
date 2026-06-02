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
        title: const Text('Hapus Customer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ctrl.delete(c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? '${c.name} berhasil dihapus'
              : ctrl.errorMessage ?? 'Gagal menghapus'),
          backgroundColor:
              success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
        ));
      }
    }
  }

  void _showOptions(BuildContext context, CustomerModel c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              c.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B2A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              c.customerNumber,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerFormScreen(customer: c),
                  ),
                );
                if (result == true && mounted) {
                  context.read<CustomerController>().fetchAll();
                }
              },
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Color.fromARGB(255, 255, 255, 255), size: 20),
              ),
              title: const Text('Edit Customer',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1B2A))),
              subtitle: const Text('Ubah data customer',
                  style:
                      TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              trailing: const Icon(Icons.chevron_right,
                  color: Color(0xFF94A3B8)),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            ListTile(
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, c);
              },
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
              ),
              title: const Text('Hapus Customer',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444))),
              subtitle: const Text('Hapus data customer ini',
                  style:
                      TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              trailing: const Icon(Icons.chevron_right,
                  color: Color(0xFF94A3B8)),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CustomerController>();

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
      backgroundColor: const Color(0xFFF8FAFC),
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
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatRow(
                                    ctrl.customers.length, todayCount),
                                const SizedBox(height: 24),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CustomerFormScreen()),
          );
          if (result == true && mounted) ctrl.fetchAll();
        },
        backgroundColor: const Color(0xFF2563EB),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.water_drop_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Verifikasi Pelanggan',
                style: TextStyle(
                  color: Color(0xFF0D1B2A),
                  fontSize: 16,
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
              width: 36,
              height: 36,
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

  Widget _buildStatRow(int total, int today) {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            label: 'Menunggu',
            value: total.toString().padLeft(2, '0'),
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statBox(
            label: 'Hari Ini',
            value: today.toString().padLeft(2, '0'),
            color: const Color(0xFF0D1B2A),
          ),
        ),
      ],
    );
  }

  Widget _statBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.0)),
      ],
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    CustomerModel c, {
    bool isNew = false,
  }) {
    String formattedDate = '-';
    try {
      final d = DateTime.parse(c.createdAt).toLocal();
      const months = [
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isNew
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFFFFBEB),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isNew
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D1B2A))),
                      const SizedBox(height: 2),
                      Text(formattedDate,
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
              ],
            ),
          ),

          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _KTPPatternPainter()),
                  ),
                  Center(
                    child: Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.person,
                                  color: Color(0xFFCBDCEC), size: 32),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 6,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB)
                                          .withOpacity(0.3),
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...List.generate(
                                    4,
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 5),
                                      child: Container(
                                        height: 5,
                                        width: i % 2 == 0 ? 80 : 60,
                                        decoration: BoxDecoration(
                                          color:
                                              const Color(0xFFE2E8F0),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Foto KTP',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 12,
              children: [
                _infoChip(Icons.numbers_rounded, c.customerNumber),
                _infoChip(Icons.water_drop_outlined,
                    c.service?.name ?? '-'),
                _infoChip(Icons.phone_outlined, c.phone),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, c),
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: Color(0xFFEF4444)),
                    label: const Text('Hapus',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerFormScreen(customer: c),
                        ),
                      );
                      if (result == true && mounted) {
                        context.read<CustomerController>().fetchAll();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: Colors.white),
                    label: const Text('Edit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildError(CustomerController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(ctrl.errorMessage ?? 'Terjadi kesalahan',
              style: const TextStyle(color: Color(0xFF5A7A99)),
              textAlign: TextAlign.center),
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

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded,
                size: 56, color: Color(0xFFCBDCEC)),
            SizedBox(height: 12),
            Text('Belum ada data pelanggan',
                style: TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _KTPPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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

    final accentPaint = Paint()
      ..color = const Color(0xFFCBDCEC)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, 40, 4), const Radius.circular(2)),
      accentPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, 4, 40), const Radius.circular(2)),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}