import 'package:flutter/material.dart';
import '../../../../routes/app_routes.dart';

class BillSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> bill;
  final String method;

  const BillSuccessScreen({super.key, required this.bill, required this.method});

  @override
  State<BillSuccessScreen> createState() => _BillSuccessScreenState();
}

class _BillSuccessScreenState extends State<BillSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    String str = number.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return result;
  }

  String _getPeriod() {
    final month = widget.bill['month'];
    final year = widget.bill['year'];
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month != null && year != null) return '${months[month]} $year';
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.bill['price'] as int? ?? 0;
    final billId = widget.bill['id'] ?? '-';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.water_drop_rounded, color: Color(0xFF0061C9)),
            SizedBox(width: 6),
            Text(
              'HydroPay',
              style: TextStyle(
                color: Color(0xFF0061C9),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // ── Animasi centang ──────────────────────────────────────────
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF16A34A),
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Judul ────────────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const Text(
                    'Pembayaran Berhasil!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pembayaran tagihan air Anda telah diproses.\nMenunggu verifikasi dari admin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Nominal besar ────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0061C9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL PEMBAYARAN',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${_formatNumber(price)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Detail transaksi ─────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('ID Tagihan', '#$billId'),
                    _buildReceiptRow('Periode', _getPeriod()),
                    _buildReceiptRow('Metode', widget.method),
                    _buildReceiptRow(
                      'Waktu',
                      '${TimeOfDay.now().format(context)} WIB',
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9C3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Menunggu Verifikasi',
                            style: TextStyle(
                              color: Color(0xFFCA8A04),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ── Tombol ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.customerDashboard,
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0061C9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}