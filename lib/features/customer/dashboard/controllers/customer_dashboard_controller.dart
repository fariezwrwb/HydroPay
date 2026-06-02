import 'package:aya_ikbal/core/services/api_service.dart';
import 'package:aya_ikbal/core/services/auth_service.dart';
import 'package:flutter/material.dart';

class CustomerDashboardController extends ChangeNotifier {
  List<Map<String, dynamic>> _bills = [];
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> get bills => _bills;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Hitung jumlah tagihan belum bayar
  int get unpaidCount {
    return _bills.where((bill) => bill['paid'] == false).length;
  }

  // Hitung total tagihan yang belum dibayar
  int get totalUnpaidAmount {
    int total = 0;
    for (var bill in _bills) {
      if (bill['paid'] == false) {
        total += (bill['price'] as int? ?? 0);
      }
    }
    return total;
  }

  // Hitung total tagihan yang sudah dibayar
  int get totalPaidAmount {
    int total = 0;
    for (var bill in _bills) {
      if (bill['paid'] == true) {
        total += (bill['price'] as int? ?? 0);
      }
    }
    return total;
  }

  
  List<Map<String, dynamic>> getMonthlyBillData() {
    final Map<String, Map<String, dynamic>> monthlyData = {};
    
    for (var bill in _bills) {
      final month = bill['month'];
      final year = bill['year'];
      final key = '$year-$month';
      final price = bill['price'] as int? ?? 0;
      final isPaid = bill['paid'] == true;
      
      if (!monthlyData.containsKey(key)) {
        monthlyData[key] = {
          'month': month,
          'year': year,
          'unpaidAmount': 0,
          'paidAmount': 0,
        };
      }
      
      if (isPaid) {
        monthlyData[key]!['paidAmount'] = (monthlyData[key]!['paidAmount'] as int) + price;
      } else {
        monthlyData[key]!['unpaidAmount'] = (monthlyData[key]!['unpaidAmount'] as int) + price;
      }
    }
    
   
    final sortedKeys = monthlyData.keys.toList()..sort((a, b) {
      final aParts = a.split('-');
      final bParts = b.split('-');
      if (aParts[0] != bParts[0]) {
        return int.parse(aParts[0]).compareTo(int.parse(bParts[0]));
      }
      return int.parse(aParts[1]).compareTo(int.parse(bParts[1]));
    });
    
    return sortedKeys.map((key) => monthlyData[key]!).toList();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        _errorMessage = 'Silakan login terlebih dahulu';
        _isLoading = false;
        notifyListeners();
        return;
      }

  
      final response = await ApiService.get('/bills/me', withToken: true);

      print('Response bills: $response');

      if (response['success'] == true) {
        _bills = List<Map<String, dynamic>>.from(response['data'] ?? []);
        print('Jumlah bills: ${_bills.length}');
        print('Unpaid count: $unpaidCount');
        print('Total unpaid: $totalUnpaidAmount');
      } else {
        _errorMessage = response['message'] ?? 'Gagal mengambil data';
      }

      // GET profile (customer/me)
      final profileResponse = await ApiService.get('/customers/me', withToken: true);
      
      if (profileResponse['success'] == true) {
        _profile = profileResponse['data'];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error: $e');
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchDashboardData();
  }
}