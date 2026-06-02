import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_service.dart';

class BillController extends ChangeNotifier {
  List<BillModel> _bills = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BillModel> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Tagihan belum bayar (paid = false)
  List<BillModel> get unpaidBills {
    return _bills.where((bill) => !bill.paid).toList();
  }

  // Tagihan menunggu verifikasi (sudah bayar tapi belum diverifikasi)
  List<BillModel> get pendingVerification {
    return _bills.where((bill) => !bill.paid && bill.payments != null && !bill.payments!.verified).toList();
  }

  // Total semua tagihan
  int get totalCount => _bills.length;

  Future<void> fetchAll() async {
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

      // Admin: GET /bills (semua data)
      final response = await ApiService.get('/bills', withToken: true);

      print('Response bills: $response');

      if (response['success'] == true) {
        final data = response['data'];
        
        if (data is List) {
          _bills = data.map((json) => BillModel.fromJson(json)).toList();
        } else {
          _bills = [];
        }
        
        print('Jumlah bills: ${_bills.length}');
        print('Unpaid count: ${unpaidBills.length}');
        print('Pending verification: ${pendingVerification.length}');
        
      } else {
        _errorMessage = response['message'] ?? 'Gagal mengambil data';
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

  Future<bool> create({
    required int customerId,
    required int month,
    required int year,
    required String measurementNumber,
    required int usageValue,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final payload = {
        'customer_id': customerId,
        'month': month,
        'year': year,
        'measurement_number': measurementNumber,
        'usage_value': usageValue,
      };

      final response = await ApiService.post('/bills', payload, withToken: true);

      if (response['success'] == true) {
        await fetchAll();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal membuat tagihan';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> update(
    int id, {
    required int month,
    required int year,
    required String measurementNumber,
    required int usageValue,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final payload = {
        'month': month,
        'year': year,
        'measurement_number': measurementNumber,
        'usage_value': usageValue,
      };

      final response = await ApiService.patch('/bills/$id', payload, withToken: true);

      if (response['success'] == true) {
        await fetchAll();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal memperbarui tagihan';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> delete(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.delete('/bills/$id', withToken: true);

      if (response['success'] == true) {
        await fetchAll();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal menghapus tagihan';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyAccepted(int paymentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.patch('/payments/$paymentId', {}, withToken: true);

      if (response['success'] == true) {
        await fetchAll();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal verifikasi';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyRejected(int paymentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.delete('/payments/$paymentId', withToken: true);

      if (response['success'] == true) {
        await fetchAll();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal menolak pembayaran';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}