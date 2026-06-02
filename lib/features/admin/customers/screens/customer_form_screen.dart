import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_controller.dart';
import '../models/customer_model.dart';
import '../../services/controllers/service_controller.dart';
import '../../../../views/widget/admin_bottom_navbar.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nameC          = TextEditingController();
  final _phoneC         = TextEditingController();
  final _addressC       = TextEditingController();
  final _customerNumberC = TextEditingController();
  final _usernameC      = TextEditingController();
  final _passwordC      = TextEditingController();

  int? _selectedServiceId;

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    // Fetch services untuk dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceController>().fetchAll();
    });

    if (isEdit) {
      _nameC.text           = widget.customer!.name;
      _phoneC.text          = widget.customer!.phone;
      _addressC.text        = widget.customer!.address;
      _customerNumberC.text = widget.customer!.customerNumber;
      _selectedServiceId    = widget.customer!.serviceId;
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _addressC.dispose();
    _customerNumberC.dispose();
    _usernameC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<CustomerController>();
    bool success;

    if (isEdit) {
      success = await ctrl.update(
        widget.customer!.id,
        customerNumber: _customerNumberC.text.trim(),
        address: _addressC.text.trim(),
        serviceId: _selectedServiceId!,
        name: _nameC.text.trim(),
        phone: _phoneC.text.trim(),
      );
    } else {
      success = await ctrl.create(
        username: _usernameC.text.trim(),
        password: _passwordC.text,
        customerNumber: _customerNumberC.text.trim(),
        address: _addressC.text.trim(),
        serviceId: _selectedServiceId!,
        name: _nameC.text.trim(),
        phone: _phoneC.text.trim(),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? isEdit
                ? 'Data pelanggan berhasil diperbarui'
                : 'Pelanggan baru berhasil ditambahkan'
            : ctrl.errorMessage ?? 'Gagal memproses data'),
        backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl        = context.watch<CustomerController>();
    final serviceCtrl = context.watch<ServiceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Ubah Data Pelanggan' : 'Tambah Pelanggan Baru',
          style: const TextStyle(
              color: Color(0xFF0D1B2A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info banner ─────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFF2563EB), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEdit
                            ? 'Perubahan data akan langsung terintegrasi dengan database pusat PDAM.'
                            : 'Pastikan data kredensial akun dan nomor meteran sudah sesuai sebelum disimpan.',
                        style: const TextStyle(
                            color: Color(0xFF1E40AF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Informasi Akun Login (hanya create) ─────────────────────
              if (!isEdit) ...[
                _buildSectionTitle('Informasi Akun Login'),
                _buildCard(children: [
                  _buildField(
                    label: 'Username',
                    hint: 'Masukkan username unik',
                    controller: _usernameC,
                    icon: Icons.account_circle_outlined,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Username wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Password Akun',
                    hint: 'Minimal 6 karakter kombinasi',
                    controller: _passwordC,
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (v) => v == null || v.length < 6
                        ? 'Password minimal 6 karakter'
                        : null,
                  ),
                ]),
                const SizedBox(height: 20),
              ],

              // ── Profil & Detail Meteran ──────────────────────────────────
              _buildSectionTitle('Profil & Detail Meteran'),
              _buildCard(children: [
                _buildField(
                  label: 'Nama Lengkap Pelanggan',
                  hint: 'Masukkan nama sesuai KTP',
                  controller: _nameC,
                  icon: Icons.person_outline_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Nomor Telepon / WhatsApp',
                  hint: 'Contoh: 081234567xxx',
                  controller: _phoneC,
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nomor telepon wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Nomor Pelanggan (Seri Meteran)',
                  hint: 'Masukkan nomor seri meteran air',
                  controller: _customerNumberC,
                  icon: Icons.confirmation_number_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nomor pelanggan wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // ── Dropdown Service ───────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Layanan',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    serviceCtrl.isLoading
                        ? Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF2563EB)),
                              ),
                            ),
                          )
                        : DropdownButtonFormField<int>(
                            value: _selectedServiceId,
                            decoration: InputDecoration(
                              hintText: 'Pilih layanan PDAM',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 13),
                              prefixIcon: const Icon(Icons.water_drop_outlined,
                                  color: Color(0xFF94A3B8), size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2563EB), width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFEF4444)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEF4444), width: 1.5),
                              ),
                            ),
                            items: serviceCtrl.services.map((s) {
                              return DropdownMenuItem<int>(
                                value: s.id,
                                child: Text(
                                  '${s.name} — Rp ${_formatRupiah(s.price)}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF0D1B2A)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedServiceId = v),
                            validator: (v) =>
                                v == null ? 'Pilih layanan terlebih dahulu' : null,
                          ),
                  ],
                ),

                const SizedBox(height: 16),
                _buildField(
                  label: 'Alamat Rumah Lengkap',
                  hint: 'Nama jalan, nomor rumah, RT/RW, dan kelurahan...',
                  controller: _addressC,
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Alamat lengkap wajib diisi' : null,
                ),
              ]),
              const SizedBox(height: 32),

              // ── Tombol submit ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF94A3B8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: ctrl.isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isEdit
                              ? 'Simpan Perubahan Data'
                              : 'Daftarkan Pelanggan Baru',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0D1B2A),
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String _formatRupiah(int price) {
    String s = price.toString();
    String r = '';
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      r = s[i] + r;
      c++;
      if (c % 3 == 0 && i != 0) r = '.$r';
    }
    return r;
  }
}