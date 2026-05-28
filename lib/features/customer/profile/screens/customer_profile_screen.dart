import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/controllers/auth_controller.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final res = await ApiService.get(ApiConstants.customerMe);
      if (res['success'] == true) {
        setState(() => _profileData = res['data']);
      } else {
        setState(() => _errorMessage = res['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat profil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.neutral)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthController>().logout();
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(_errorMessage!,
                            style:
                                const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _fetchProfile,
                          child: const Text('Coba Lagi',
                              style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final name = _profileData?['name'] ?? '-';
    final customerNumber = _profileData?['customer_number'] ?? '-';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop,
                          color: AppColors.primary, size: 26),
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
                      _iconButton(Icons.settings_outlined, () {}),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Profile Image (Avatar)
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                color: AppColors.neutralLight,
              ),
              child: const ClipOval(
                child: Icon(
                  Icons.person,
                  size: 56,
                  color: AppColors.neutral,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Name & ID Pelanggan
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID Pelanggan: $customerNumber',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // Menu Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                    _menuTile(
                      icon: Icons.settings_outlined,
                      iconBg: AppColors.primary.withOpacity(0.12),
                      iconColor: AppColors.primary,
                      label: 'Pengaturan Akun',
                      onTap: () {},
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.payments_outlined,
                      iconBg: AppColors.tertiary.withOpacity(0.12),
                      iconColor: AppColors.tertiary,
                      label: 'Metode Pembayaran',
                      onTap: () {},
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.help_outline,
                      iconBg: AppColors.neutral.withOpacity(0.15),
                      iconColor: AppColors.neutral,
                      label: 'Bantuan',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                child: _menuTile(
                  icon: Icons.logout_rounded,
                  iconBg: AppColors.error.withOpacity(0.12),
                  iconColor: AppColors.error,
                  label: 'Keluar',
                  labelColor: AppColors.error,
                  showChevron: false,
                  onTap: _logout,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
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

  Widget _menuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    Color? labelColor,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right,
                  color: AppColors.neutral, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: AppColors.divider,
    );
  }
}