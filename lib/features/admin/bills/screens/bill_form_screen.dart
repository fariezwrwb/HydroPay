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
          content: Text(_isEdit ? 'Tagihan berhasil diperbarui' : 'Tagihan berhasil dibuat'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ctrl.errorMessage ?? 'Gagal menyimpan tagihan'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        content: const Text('Yakin ingin menghapus tagihan ini?', style: TextStyle(color: Color(0xFF64748B))),
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
      final ok = await ctrl.delete(widget.bill!.id);
      if (mounted) {
        if (ok) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ctrl.errorMessage ?? 'Gagal menghapus'),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF1F2937)),
        ),
        title: Text(
          _isEdit ? 'Edit Tagihan' : 'Buat Tagihan Baru',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
            fontSize: 16,
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
              _buildInfoCard(),
              const SizedBox(height: 24),
              if (!_isEdit) _buildCustomerDropdown(customerCtrl),
              if (!_isEdit) const SizedBox(height: 20),
              _buildPeriodSection(),
              const SizedBox(height: 20),
              _buildMeterSection(),
              const SizedBox(height: 32),
              _buildActionButtons(ctrl),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isEdit
                  ? 'Perubahan tagihan tidak akan mempengaruhi data pembayaran yang sudah ada.'
                  : 'Isi data tagihan air pelanggan dengan lengkap.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF3B82F6), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDropdown(CustomerController customerCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Pelanggan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: customerCtrl.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)))),
                )
              : DropdownButtonFormField<int>(
                  value: _selectedCustomerId,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    hintText: 'Pilih pelanggan',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  items: customerCtrl.customers.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.name} (${c.customerNumber})', style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCustomerId = v),
                  validator: (v) => v == null ? 'Pilih pelanggan' : null,
                ),
        ),
      ],
    );
  }

  Widget _buildPeriodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Periode Tagihan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    prefixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFF94A3B8)),
                  ),
                  items: List.generate(12, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(_months[i], style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
                  )),
                  onChanged: (v) => setState(() => _selectedMonth = v!),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    prefixIcon: Icon(Icons.calendar_month, size: 18, color: Color(0xFF94A3B8)),
                  ),
                  items: List.generate(5, (i) {
                    final y = DateTime.now().year - 2 + i;
                    return DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))));
                  }),
                  onChanged: (v) => setState(() => _selectedYear = v!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Meteran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: TextFormField(
            controller: _measureC,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: const InputDecoration(
              hintText: 'Contoh: MTR-2024-001',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: Icon(Icons.speed, size: 18, color: Color(0xFF94A3B8)),
            ),
            validator: (v) => v!.isEmpty ? 'Nomor meteran wajib diisi' : null,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: TextFormField(
            controller: _usageC,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: const InputDecoration(
              hintText: 'Jumlah pemakaian (m³)',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: Icon(Icons.water_drop, size: 18, color: Color(0xFF94A3B8)),
            ),
            validator: (v) {
              if (v!.isEmpty) return 'Wajib diisi';
              if (int.tryParse(v) == null) return 'Masukkan angka';
              if (int.parse(v) < 0) return 'Tidak boleh negatif';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BillController ctrl) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: ctrl.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: ctrl.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(
                    _isEdit ? 'Simpan Perubahan' : 'Buat Tagihan',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
          ),
        ),
        if (_isEdit) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: ctrl.isLoading ? null : _hapus,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Hapus Tagihan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
            ),
          ),
        ],
      ],
    );
  }
}