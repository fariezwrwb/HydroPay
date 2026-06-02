import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/customer_controller.dart';
import '../models/customer_model.dart';
import '../../../../views/widget/admin_bottom_navbar.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? customer;

  const CustomerFormScreen({
    super.key,
    this.customer,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _addressC = TextEditingController();
  final _customerNumberC = TextEditingController();
  final _serviceIdC = TextEditingController();
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameC.text = widget.customer!.name;
      _phoneC.text = widget.customer!.phone;
      _addressC.text = widget.customer!.address;
      _customerNumberC.text = widget.customer!.customerNumber;
      _serviceIdC.text = widget.customer!.serviceId.toString();
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _addressC.dispose();
    _customerNumberC.dispose();
    _serviceIdC.dispose();
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
        serviceId: int.tryParse(_serviceIdC.text.trim()) ?? 0,
        name: _nameC.text.trim(),
        phone: _phoneC.text.trim(),
      );
    } else {
      success = await ctrl.create(
        username: _usernameC.text.trim(),
        password: _passwordC.text,
        customerNumber: _customerNumberC.text.trim(),
        address: _addressC.text.trim(),
        serviceId: int.tryParse(_serviceIdC.text.trim()) ?? 0,
        name: _nameC.text.trim(),
        phone: _phoneC.text.trim(),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? isEdit ? 'Data pelanggan berhasil diperbarui' : 'Pelanggan baru berhasil ditambahkan'
            : ctrl.errorMessage ?? 'Gagal memproses data'),
        backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CustomerController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Ubah Data Pelanggan' : 'Tambah Pelanggan Baru',
          style: const TextStyle(
            color: Color(0xFF0D1B2A), 
            fontWeight: FontWeight.bold, 
            fontSize: 18
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: false,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit 
                          ? 'Perubahan data akan langsung terintegrasi dengan database pusat PDAM.' 
                          : 'Pastikan data kredensial akun dan nomor meteran sudah sesuai sebelum disimpan.',
                        style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              if (!isEdit) ...[
                _buildSectionTitle('Informasi Akun Login'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildField(
                        label: 'Username',
                        hint: 'Masukkan username unik',
                        controller: _usernameC,
                        icon: Icons.account_circle_outlined,
                        validator: (v) => v == null || v.isEmpty ? 'Username wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Password Akun',
                        hint: 'Minimal 6 karakter kombinasi',
                        controller: _passwordC,
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (v) => v == null || v.length < 6 ? 'Password minimal 6 karakter' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _buildSectionTitle('Profil & Detail Meteran'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildField(
                      label: 'Nama Lengkap Pelanggan',
                      hint: 'Masukkan nama sesuai KTP',
                      controller: _nameC,
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Nomor Telepon / WhatsApp',
                      hint: 'Contoh: 081234567xxx',
                      controller: _phoneC,
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'Nomor telepon wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Nomor Pelanggan (Seri Meteran)',
                      hint: 'Masukkan nomor seri meteran air',
                      controller: _customerNumberC,
                      icon: Icons.confirmation_number_outlined,
                      validator: (v) => v == null || v.isEmpty ? 'Nomor pelanggan wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Service ID',
                      hint: 'Masukkan kode kategori layanan',
                      controller: _serviceIdC,
                      icon: Icons.water_drop_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Service ID wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Alamat Rumah Lengkap',
                      hint: 'Nama jalan, nomor rumah, RT/RW, dan kelurahan...',
                      controller: _addressC,
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty ? 'Alamat lengkap wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF94A3B8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: ctrl.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isEdit ? 'Simpan Perubahan Data' : 'Daftarkan Pelanggan Baru',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.3),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: Color(0xFF475569)
        ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}