import 'package:aya_ikbal/features/admin/services/controllers/service_controller.dart';
import 'package:aya_ikbal/features/admin/services/models/service_model.dart';
import 'package:aya_ikbal/features/admin/services/screens/service_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../routes/app_routes.dart';
import 'package:intl/intl.dart';
import '../../../../../../views/widget/admin_bottom_navbar.dart';
import '../../../../../../core/constants/app_colors.dart';



class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  
  final List<Map<String, dynamic>> _iconThemes = [
    {
      'icon': Icons.water_drop_rounded,
      'bg': Color(0xFFEFF6FF), // Blue 50
      'color': Color(0xFF2563EB),
    },
    {
      'icon': Icons.home_work_rounded,
      'bg': Color(0xFFFFF7ED), // Orange 50
      'color': Color(0xFFF97316),
    },
    {
      'icon': Icons.domain_rounded,
      'bg': Color(0xFFF0FDF4), // Green 50
      'color': Color(0xFF22C55E),
    },
    {
      'icon': Icons.account_balance_rounded,
      'bg': Color(0xFFFDF4FF), // Purple 50
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

  Future<void> _confirmDelete(ServiceModel s) async {
    final ctrl = context.read<ServiceController>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Kategori',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
        ),
        content: Text('Apakah Anda yakin ingin menghapus tarif layanan "${s.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ctrl.delete(s.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '"${s.name}" berhasil dihapus' : ctrl.errorMessage ?? 'Gagal menghapus'),
            backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ServiceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
     appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), AppColors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 8),
            Text(
              'Kategori Layanan',
              style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF64748B), size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Riwayat perubahan tarif belum tersedia')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminProfile),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF2563EB),
                child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : RefreshIndicator(
              onRefresh: () => ctrl.fetchAll(),
              color: const Color(0xFF2563EB),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(ctrl),
                    const SizedBox(height: 24),
                    const Text(
                      'Daftar Golongan Tarif',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    if (ctrl.errorMessage != null)
                      _buildError(ctrl)
                    else if (ctrl.services.isEmpty)
                      _buildEmpty()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ctrl.services.length,
                        itemBuilder: (context, index) {
                          return _buildServiceItem(ctrl.services[index], index);
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildOverviewCard(ServiceController ctrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Golongan Aktif',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Text(
                '${ctrl.services.length} Layanan',
                style: const TextStyle(color: Color(0xFF0D1B2A), fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Telah disesuaikan dengan regulasi pusat',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: ctrl.services.isEmpty ? 0.0 : 1.0,
                  backgroundColor: const Color(0xFFF1F5F9),
                  color: const Color(0xFF2563EB),
                  strokeWidth: 5,
                ),
              ),
              const Icon(Icons.assessment_rounded, color: Color(0xFF2563EB), size: 22),
            ],
          )
        ],
      ),
    );
  }


  Widget _buildServiceItem(ServiceModel s, int index) {
    final theme = _iconThemes[index % _iconThemes.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme['bg'] as Color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(theme['icon'] as IconData, color: theme['color'] as Color, size: 22),
        ),
        title: Text(
          s.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Batas: ${s.minUsage} - ${s.maxUsage} m³',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatRupiah(s.price),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
                ),
                const Text(
                  'per m³',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  _openForm(service: s);
                } else if (val == 'delete') {
                  _confirmDelete(s);
                }
              },
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B), size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 16, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text('Ubah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFEF4444))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildError(ServiceController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 44, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              ctrl.errorMessage ?? 'Gagal memuat data tarif',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => ctrl.fetchAll(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Icon(Icons.layers_clear_outlined, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'Belum ada kategori layanan',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Silakan tambahkan golongan tarif baru melalui tombol +',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}