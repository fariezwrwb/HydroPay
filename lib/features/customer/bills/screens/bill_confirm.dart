import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/payment_controller.dart';
import 'bill_success_screen.dart';

class BillConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> bill;

  const BillConfirmScreen({super.key, required this.bill});

  @override
  State<BillConfirmScreen> createState() => _BillConfirmScreenState();
}

class _BillConfirmScreenState extends State<BillConfirmScreen> {
  String _selectedMethod = 'HydroPay Balance';

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PaymentController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0061C9)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Konfirmasi Bayar', style: TextStyle(color: Color(0xFF0061C9), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tagihan Air', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                        child: Text('#${widget.bill['id'] ?? '256374'}', style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Periode', widget.bill['month'] ?? 'Juni 2026'),
                  _buildSummaryRow('Nomor Pelanggan', widget.bill['customer_id'].toString()),
                  _buildSummaryRow('Pemakaian', '${widget.bill['usage'] ?? '0'} m³'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text('Rp ${widget.bill['total_price'] ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0061C9), fontSize: 16)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            _buildMethodCard('HydroPay Balance', 'Saldo: Rp 5.250.000', Icons.account_balance_wallet_rounded),
            const SizedBox(height: 12),
            _buildMethodCard('Bank Transfer', 'BCA, Mandiri, BNI, BRI', Icons.account_balance_rounded),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                SizedBox(width: 6),
                Text('Pembayaran aman dengan enkripsi', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: ctrl.isLoading
                    ? null
                    : () async {
                        final ok = await context.read<PaymentController>().payBill(
                              int.parse(widget.bill['id'].toString()),
                              _selectedMethod,
                            );
                        if (ok && mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => BillSuccessScreen(bill: widget.bill, method: _selectedMethod)),
                            (route) => route.isFirst,
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ctrl.errorMessage ?? 'Gagal membayar'), backgroundColor: Colors.red),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0061C9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: ctrl.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          Text(val, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMethodCard(String id, String subtitle, IconData icon) {
    bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF0061C9) : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFF0061C9), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(id, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFF0061C9) : const Color(0xFFCBD5E1), width: isSelected ? 5 : 1.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}