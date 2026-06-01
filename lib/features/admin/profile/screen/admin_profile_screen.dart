import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../auth/screens/login_screen.dart';
import '../../../../routes/app_routes.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
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
      final res = await ApiService.get(
        ApiConstants.adminMe,
        withToken: true, // ← WAJIB: pakai token JWT
      );
      if (res['success'] == true) {
        setState(() {
          _profileData = res['data'];
        });
      } else {
        setState(() {
          _errorMessage = res['message'] ?? 'Gagal memuat profil';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat profil';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.red, size: 34),
              ),
              const SizedBox(height: 16),
              const Text('Keluar Akun',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Apakah kamu yakin ingin keluar dari akun admin?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Keluar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;
    await context.read<AuthController>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Response dari /admins/me:
    // data.name, data.phone, data.user.username
    final name = _profileData?['name'] ?? 'Administrator';
    final phone = _profileData?['phone'] ?? '-';
    // username ada di dalam nested 'user'
    final username =
        (_profileData?['user'] as Map<String, dynamic>?)?['username'] ??
            '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_errorMessage!,
                            style:
                                const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchProfile,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary),
                          child: const Text('Coba Lagi',
                              style:
                                  TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchProfile,
                    child: SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.pop(context),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(.05),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                        Icons
                                            .arrow_back_ios_new_rounded,
                                        size: 18),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Text('Profil Admin',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.bold)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Avatar
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withOpacity(.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              size: 55,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              )),
                          const SizedBox(height: 6),
                          Text(username,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),

                          const SizedBox(height: 30),

                          // Info card
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(.05),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _infoTile(Icons.person_outline,
                                      'Nama', name),
                                  const Divider(),
                                  _infoTile(
                                      Icons.account_circle_outlined,
                                      'Username',
                                      username),
                                  const Divider(),
                                  _infoTile(Icons.phone_outlined,
                                      'Nomor HP', phone),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Menu navigasi
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(.05),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _menuTile(
                                    icon: Icons.people_alt_outlined,
                                    label: 'Kelola Pelanggan',
                                    color: Colors.green,
                                    onTap: () => Navigator
                                        .pushNamed(
                                            context,
                                            AppRoutes
                                                .adminCustomers),
                                  ),
                                  const Divider(height: 1),
                                  _menuTile(
                                    icon: Icons
                                        .receipt_long_outlined,
                                    label: 'Kelola Tagihan',
                                    color: Colors.orange,
                                    onTap: () => Navigator
                                        .pushNamed(context,
                                            AppRoutes.adminBills),
                                  ),
                                  const Divider(height: 1),
                                  _menuTile(
                                    icon: Icons
                                        .miscellaneous_services_outlined,
                                    label: 'Kelola Layanan',
                                    color: Colors.purple,
                                    onTap: () => Navigator
                                        .pushNamed(
                                            context,
                                            AppRoutes
                                                .adminServices),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Tombol Keluar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                              child: _menuTile(
                                icon: Icons.logout_rounded,
                                label: 'Keluar',
                                color: Colors.red,
                                showArrow: false,
                                onTap: _logout,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color == Colors.red
                      ? Colors.red
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.grey),
          ],
        ),
      ),
    );
  }
}