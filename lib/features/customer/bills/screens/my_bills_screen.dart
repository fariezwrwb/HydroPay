import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/payment_controller.dart'; 
import 'bill_detail_screens.dart'; 

class MyBillsScreen extends StatefulWidget {
  const MyBillsScreen({super.key});

  @override
  State<MyBillsScreen> createState() => _MyBillsScreenState();
}

class _MyBillsScreenState extends State<MyBillsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentController>().fetchCustomerBills();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PaymentController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tagihan Air',
          style: TextStyle(color: Color(0xFF0061C9), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0061C9),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF0061C9),
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Riwayat Lunas'),
          ],
        ),
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBillList(ctrl.activeBills, isHistory: false),
                _buildBillList(ctrl.historyBills, isHistory: true),
              ],
            ),
    );
  }

  Widget _buildBillList(List<dynamic> list, {required bool isHistory}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isHistory ? Icons.history_rounded : Icons.receipt_long_rounded, size: 48, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(isHistory ? 'Belum ada riwayat pembayaran' : 'Tidak ada tagihan aktif', style: const TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final bill = list[index];
        return GestureDetector(
          onTap: () {
            if (!isHistory) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BillDetailScreen(bill: bill)),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bulan ${bill['month'] ?? 'Juni 2026'}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHistory ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isHistory ? 'Lunas' : 'Belum Bayar',
                        style: TextStyle(
                          color: isHistory ? const Color(0xFF15803D) : const Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Penggunaan Air', style: TextStyle(color: Color(0xFF64748B))),
                    Text('${bill['usage'] ?? '0'} m³', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Nominal', style: TextStyle(color: Color(0xFF64748B))),
                    Text(
                      'Rp ${bill['total_price'] ?? '0'}',
                      style: TextStyle(
                        color: isHistory ? const Color(0xFF1E293B) : const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}