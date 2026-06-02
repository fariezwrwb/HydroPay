import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/bill_controller.dart';
import '../models/bill_model.dart';
import '../../customers/controllers/customer_controller.dart';

class BillFormScreen extends StatefulWidget {
  final BillModel? bill; 

  const BillFormScreen({super.key, this.bill});

  @override
  State<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends State<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _measureC = TextEditingController();
  final _usageC = TextEditingController();

  int? _selectedCustomerId;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool get _isEdit => widget.bill != null;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerController>().fetchAll();
    });
    if (_isEdit) {
      final b = widget.bill!;
      _selectedCustomerId = b.customerId;
      _selectedMonth = b.month;
      _selectedYear = b.year;
      _measureC.text = b.measurementNumber;
      _usageC.text = b.usageValue.toString();
    }
  }

  @override
  void dispose() {
    _measureC.dispose();
    _usageC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<BillController>();
    bool success;

    if (_isEdit) {

      success = await ctrl.update(
        widget.bill!.id,
        month: _selectedMonth,
        year: _selectedYear,
        measurementNumber: _measureC.text.trim(),
        usageValue: int.parse(_usageC.text.trim()),
      );
    } else {
  
      success = await ctrl.create(
        customerId: _selectedCustomerId!,
        month: _selectedMonth,
        year: _selectedYear,
        measurementNumber: _measureC.text.trim(),
        usageValue: int.parse(_usageC.text.trim()),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Tagihan berhasil diperbarui'
              : 'Tagihan berhasil dibuat'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(ctrl.errorMessage ?? 'Gagal menyimpan tagihan'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _hapus() async {
    final ctrl = context.read<BillController>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tagihan',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('Yakin ingin menghapus tagihan ini?'),
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
      final ok = await ctrl.delete(widget.bill!.id);
      if (mounted) {
        if (ok) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(ctrl.errorMessage ?? 'Gagal menghapus'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BillController>();
    final customerCtrl = context.watch<CustomerController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
            bottom:
                BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: Color(0xFF0D1B2A)),
        ),
        titleSpacing: 0,
        title: Text(
          _isEdit ? 'Edit Tagihan' : 'Tambah Tagihan',
          style: const TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFBFDBFE), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEdit
                            ? 'Perubahan tagihan tidak mengubah data pembayaran yang sudah ada.'
                            : 'Isi data tagihan air pelanggan.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3B82F6),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

           
              if (!_isEdit) ...[
                _buildLabel('Customer'),
                const SizedBox(height: 6),
                customerCtrl.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF2563EB)))
                    : DropdownButtonFormField<int>(
                        value: _selectedCustomerId,
                        decoration: _inputDeco(
                            'Pilih customer',
                            Icons.person_rounded),
                        items: customerCtrl.customers
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    '${c.name} (${c.customerNumber})',
                                    style: const TextStyle(
                                        fontSize: 13),
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(
                            () => _selectedCustomerId = v),
                        validator: (v) => v == null
                            ? 'Pilih customer'
                            : null,
                      ),
                const SizedBox(height: 16),
              ],

              // Periode (Bulan & Tahun)
              _buildLabel('Periode'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: _inputDeco(
                          'Bulan', Icons.calendar_today_rounded),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(_months[i],
                              style: const TextStyle(
                                  fontSize: 13)),
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => _selectedMonth = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: _inputDeco(
                          'Tahun', Icons.event_rounded),
                      items: List.generate(
                        5,
                        (i) {
                          final y =
                              DateTime.now().year - 2 + i;
                          return DropdownMenuItem(
                              value: y,
                              child: Text('$y',
                                  style: const TextStyle(
                                      fontSize: 13)));
                        },
                      ),
                      onChanged: (v) =>
                          setState(() => _selectedYear = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // No. Meter
              _buildLabel('No. Meteran'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _measureC,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF0D1B2A)),
                decoration: _inputDeco(
                    'cth. MTR-2024-001', Icons.speed_rounded),
                validator: (v) => v!.isEmpty
                    ? 'No. meteran wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // Penggunaan
              _buildLabel('Penggunaan (m³)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _usageC,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF0D1B2A)),
                decoration: _inputDeco(
                    '0', Icons.water_drop_rounded),
                validator: (v) {
                  if (v!.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null)
                    return 'Angka saja';
                  if (int.parse(v) < 0)
                    return 'Tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: ctrl.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5),
                        )
                      : Text(
                          _isEdit
                              ? 'Simpan Perubahan'
                              : 'Buat Tagihan',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // Tombol Hapus (mode edit saja)
              if (_isEdit) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed:
                        ctrl.isLoading ? null : _hapus,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Hapus Tagihan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E3A5F),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: Color(0xFFAEC6DE), fontSize: 13),
      prefixIcon:
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: Color(0xFFCBDCEC), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: Color(0xFFCBDCEC), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}