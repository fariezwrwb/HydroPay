import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/bill_model.dart';

class BillController extends ChangeNotifier {
  List<BillModel> bills = [];
  bool isLoading = false;
  String? errorMessage;
  int totalCount = 0;

 
  Future<void> fetchAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.get(
        ApiConstants.bills,
        withToken: true,
      );
      if (res['success'] == true) {
        bills = (res['data'] as List)
            .map((e) => BillModel.fromJson(e))
            .toList();
        totalCount = res['count'] ?? bills.length;
      } else {
        errorMessage = res['message'] ?? 'Gagal memuat tagihan';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── CREATE ───────────────────────────────────────────────
  // Payload sesuai soal: customer_id, month, year,
  // measurement_number, usage_value
  Future<bool> create({
    required int customerId,
    required int month,
    required int year,
    required String measurementNumber,
    required int usageValue,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.post(
        ApiConstants.bills,
        {
          'customer_id': customerId,
          'month': month,
          'year': year,
          'measurement_number': measurementNumber,
          'usage_value': usageValue,
        },
        withToken: true,
      );
      if (res['success'] == true) {
        await fetchAll();
        return true;
      }
      errorMessage = res['message'] ?? 'Gagal membuat tagihan';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
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
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.patch(
        '${ApiConstants.bills}/$id',
        {
          'month': month,
          'year': year,
          'measurement_number': measurementNumber,
          'usage_value': usageValue,
        },
        withToken: true,
      );
      if (res['success'] == true) {
        await fetchAll();
        return true;
      }
      errorMessage = res['message'] ?? 'Gagal mengupdate tagihan';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

 
  Future<bool> delete(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.delete(
        '${ApiConstants.bills}/$id',
        withToken: true,
      );
      if (res['success'] == true) {
        await fetchAll();
        return true;
      }
      errorMessage = res['message'] ?? 'Gagal menghapus tagihan';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── VERIFY ACCEPTED ──────────────────────────────────────
  // PATCH /payments/{payment_id}
  Future<bool> verifyAccepted(int paymentId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.patch(
        '${ApiConstants.payments}/$paymentId',
        {},
        withToken: true,
      );
      if (res['success'] == true) {
        await fetchAll();
        return true;
      }
      errorMessage =
          res['message'] ?? 'Gagal memverifikasi pembayaran';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> verifyRejected(int paymentId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.delete(
        '${ApiConstants.payments}/$paymentId',
        withToken: true,
      );
      if (res['success'] == true) {
        await fetchAll();
        return true;
      }
      errorMessage = res['message'] ?? 'Gagal menolak pembayaran';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

 
  List<BillModel> get unpaidBills =>
      bills.where((b) => !b.paid).toList();

  List<BillModel> get pendingVerification =>
      bills.where((b) => b.hasPendingPayment).toList();
}