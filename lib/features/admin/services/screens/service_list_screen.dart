import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/service_controller.dart';
import '../models/service_model.dart';
import '../screens/service_form_screen.dart';
import '../../../../routes/app_routes.dart';
import 'package:intl/intl.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  int _selectedNav = 2; // Bills aktif sesuai UI/UX

  // Icon & color mapping per index (bisa disesuaikan)
  final List<Map<String, dynamic>> _iconThemes = [
    {
      'icon': Icons.home_rounded,
      'bg': Color(0xFFEFF6FF),
      'color': Color(0xFF2563EB),
    },
    {
      'icon': Icons.business_rounded,
      'bg': Color(0xFFFFF7ED),
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': Icons.factory_rounded,
      'bg': Color(0xFFF0FDF4),
      'color': Color(0xFF22C55E),
    },
    {
      'icon': Icons.park_rounded,
      'bg': Color(0xFFFDF4FF),
      'color': Color(0xFFA855F7),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceController>().fetchAll();
    });
  }

  void _onNavTap(int index) {
    setState(() => _selectedNav = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.adminCustomers);
        break;
      case 3:
        // Analytics
        break;
    }
  }

  Future<void> _confirmDelete(ServiceModel s) async {
    final ctrl = context.read<ServiceController>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Layanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus layanan "${s.name}"?'),
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
      final success = await ctrl.delete(s.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '"${s.name}" berhasil dihapus'
                : ctrl.errorMessage ?? 'Gagal menghapus'),
            backgroundColor:
                success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _openForm({ServiceModel? service}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceFormScreen(service: service),
      ),
    );
    if (result == true && mounted) {
      context.read<ServiceController>().fetchAll();
    }
  }

  String _formatRupiah(int price) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(price);
  }

  String _lastUpdated(List<ServiceModel> services) {
    if (services.isEmpty) return '-';
    try {
      final latest = services
          .map((s) => DateTime.parse(s.updatedAt))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${latest.day} ${months[latest.month]}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ServiceController>();

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
                  : RefreshIndicator(
                      onRefresh: () => ctrl.fetchAll(),
                      color: const Color(0xFF2563EB),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroCard(ctrl),
                            const SizedBox(height: 20),
                            _buildSectionHeader(),
                            const SizedBox(height: 12),
                            if (ctrl.errorMessage != null)
                              _buildError(ctrl)
                            else if (ctrl.services.isEmpty)
                              _buildEmpty()
                            else
                              ...ctrl.services.asMap().entries.map(
                                    (e) => _buildServiceCard(e.value, e.key),
                                  ),
                            const SizedBox(height: 16),
                            _buildInfoBox(),
                            const SizedBox(height: 8),
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
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF2563EB),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
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
                child: const Icon(Icons.water_drop_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Manajemen Tarif',
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
                  color: Color(0xFF2563EB), shape: BoxShape.circle),
              child: const Center(
                child: Text('AD',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO CARD ────────────────────────────────────────────
  Widget _buildHeroCard(ServiceController ctrl) {
    final lastUpdated = _lastUpdated(ctrl.services);
    final lastService = ctrl.services.isNotEmpty ? ctrl.services.last.name : 'Residential';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background circles
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
            bottom: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Active Tariffs
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE TARIFFS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${ctrl.services.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: Last Updated badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LAST UPDATED',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastUpdated,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        lastService,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION HEADER ───────────────────────────────────────
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Daftar Kategori',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1B2A),
          ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Riwayat Perubahan belum tersedia')),
            );
          },
          child: Row(
            children: const [
              Icon(Icons.history_rounded,
                  size: 14, color: Color(0xFF2563EB)),
              SizedBox(width: 4),
              Text(
                'Riwayat Perubahan',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── SERVICE CARD ─────────────────────────────────────────
  Widget _buildServiceCard(ServiceModel s, int index) {
    final theme = _iconThemes[index % _iconThemes.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          // Top row: icon + info + price
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme['bg'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    theme['icon'] as IconData,
                    color: theme['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Name & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${s.minUsage} - ${s.maxUsage} m³',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRupiah(s.price),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme['color'] as Color,
                      ),
                    ),
                    const Text(
                      'per m³',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Action row: Edit + Chart icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Edit button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openForm(service: s),
                    icon: const Icon(Icons.edit_rounded,
                        size: 14, color: Color(0xFF2563EB)),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBDCEC)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Chart / trend icon button
                GestureDetector(
                  onTap: () => _confirmDelete(s),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
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

  // ─── INFO BOX ─────────────────────────────────────────────
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembaruan Tarif',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Perubahan tarif akan berlaku efektif pada siklus penagihan bulan berikutnya. Pastikan untuk memberitahukan pelanggan melalui notifikasi aplikasi.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF3B82F6),
                    height: 1.5,
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
  Widget _buildError(ServiceController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
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
      ),
    );
  }

  // ─── EMPTY ────────────────────────────────────────────────
  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.layers_outlined,
                size: 56, color: Color(0xFFCBDCEC)),
            SizedBox(height: 12),
            Text(
              'Belum ada layanan',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Tap + untuk menambah kategori tarif',
              style: TextStyle(color: Color(0xFFCBDCEC), fontSize: 12),
            ),
          ],
        ),
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