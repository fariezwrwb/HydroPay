import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aya_ikbal/core/services/api_service.dart';
import 'package:aya_ikbal/core/services/auth_service.dart';

class PaymentController extends ChangeNotifier {
  List<dynamic> activeBills = [];
  List<dynamic> historyBills = [];
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> get getTransactions => transactions;

  int get unpaidCount => activeBills.length;

  int get totalUnpaidAmount {
    int total = 0;
    for (var bill in activeBills) {
      total += (bill['price'] as int? ?? 0);
    }
    return total;
  }

  Future<void> fetchCustomerBills() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        errorMessage = 'Silakan login terlebih dahulu';
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await ApiService.get('/bills/me', withToken: true);

      if (response['success'] == true) {
        final allBills = response['data'] as List? ?? [];
        activeBills = allBills.where((b) => b['paid'] == false).toList();
        historyBills = allBills.where((b) => b['paid'] == true).toList();
      } else {
        errorMessage = response['message'] ?? 'Gagal mengambil data';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPaymentHistory() async {
    isLoading = true;
    errorMessage = null;
    transactions = [];
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        errorMessage = 'Silakan login terlebih dahulu';
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await ApiService.get('/payments?page=1&quantity=100', withToken: true);

      if (response['success'] == true) {
        final payments = response['data'] as List? ?? [];

        for (var payment in payments) {
          final bill = payment['bill'] ?? {};
          final service = bill['service'] ?? {};

          String paymentDate = payment['payment_date'] ?? DateTime.now().toIso8601String();
          DateTime dateTime;
          try {
            dateTime = DateTime.parse(paymentDate);
          } catch (e) {
            dateTime = DateTime.now();
          }

          transactions.add({
            'type': 'bill',
            'amount': payment['total_amount'] ?? 0,
            'date': '${dateTime.day} ${_getMonthName(dateTime.month)}',
            'time': '${dateTime.hour.toString().padLeft(2, '0')}.${dateTime.minute.toString().padLeft(2, '0')}',
            'title': service['name'] ?? 'PDAM Kota Kita',
            'month': dateTime.month,
            'year': dateTime.year,
            'fullDate': dateTime,
            'verified': payment['verified'] ?? false,
          });
        }

        transactions.sort((a, b) =>
            (b['fullDate'] as DateTime).compareTo(a['fullDate'] as DateTime));
      } else {
        errorMessage = response['message'] ?? 'Gagal mengambil data';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllBillsForHistory() async {
    isLoading = true;
    errorMessage = null;
    transactions = [];
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        errorMessage = 'Silakan login terlebih dahulu';
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await ApiService.get('/bills/me', withToken: true);

      print('Response bills for history: $response');

      if (response['success'] == true) {
        final bills = response['data'] as List? ?? [];
        
        for (var bill in bills) {
          final isPaid = bill['paid'] == true;
          final payments = bill['payments'];
          final isVerified = payments != null && payments['verified'] == true;
          final service = bill['service'] ?? {};
          
          transactions.add({
            'type': 'bill',
            'amount': bill['price'] ?? 0,
            'title': service['name'] ?? 'PDAM Kota Kita',
            'month': bill['month'] ?? 1,
            'year': bill['year'] ?? DateTime.now().year,
            'isPaid': isPaid,
            'verified': isVerified,
            'billData': bill,
          });
        }
        
        transactions.sort((a, b) {
          final aDate = DateTime(a['year'], a['month']);
          final bDate = DateTime(b['year'], b['month']);
          return bDate.compareTo(aDate);
        });
        
      } else {
        errorMessage = response['message'] ?? 'Gagal mengambil数据';
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error: $e');
      errorMessage = 'Terjadi kesalahan: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPayment(int billId, String filePath) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        errorMessage = 'Silakan login terlebih dahulu';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await ApiService.postMultipart(
        '/payments',
        fields: {'bill_id': billId.toString()},
        filePath: filePath,
        fileField: 'file',
      );

      if (response['success'] == true) {
        await fetchPaymentHistory();
        return true;
      } else {
        errorMessage = response['message'] ?? 'Gagal membuat pembayaran';
        return false;
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payBill(int billId, String method, String filePath) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        errorMessage = 'Silakan login terlebih dahulu';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await ApiService.postMultipart(
        '/payments',
        fields: {'bill_id': billId.toString()},
        filePath: filePath,
        fileField: 'file',
      );

      print('=== RESPONSE BACKEND ===');
      print(response);

      if (response['success'] == true) {
        await fetchCustomerBills();
        await fetchPaymentHistory();
        await fetchAllBillsForHistory();
        return true;
      } else {
        errorMessage = response['message'] ?? 'Gagal melakukan pembayaran';
        return false;
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  String _getMonthYearName(int month, int year) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[month - 1]} $year';
  }

  String formatNumber(int number) {
    final str = number.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return result;
  }

  List<Map<String, dynamic>> getGroupedTransactions({String filter = 'Semua'}) {
    var filtered = List<Map<String, dynamic>>.from(transactions);

    if (filter == 'Tagihan Air') {
      filtered = filtered.where((t) => t['type'] == 'bill').toList();
    } else if (filter == 'Top Up') {
      filtered = filtered.where((t) => t['type'] == 'topup').toList();
    } else if (filter == 'Lainnya') {
      filtered = filtered.where((t) => t['type'] != 'bill' && t['type'] != 'topup').toList();
    }

    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var transaction in filtered) {
      final key = '${transaction['year']}-${transaction['month']}';
      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((key) {
      final parts = key.split('-');
      return {
        'monthYear': _getMonthYearName(int.parse(parts[1]), int.parse(parts[0])),
        'transactions': grouped[key]!,
      };
    }).toList();
  }
}