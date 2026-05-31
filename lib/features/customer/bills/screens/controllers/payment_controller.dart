import 'package:flutter/material.dart';
import '../../../../../../core/services/api_service.dart';
import '../../../../../../core/constants/api_constants.dart';


class PaymentController extends ChangeNotifier {
  List<dynamic> activeBills = [];
  List<dynamic> historyBills = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchCustomerBills() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.get('${ApiConstants.baseUrl}/bills/customer');
      if (res['success'] == true) {
        final allBills = res['data'] as List;
        activeBills = allBills.where((b) => b['status'] == 'PENDING' || b['status'] == 'UNPAID').toList();
        historyBills = allBills.where((b) => b['status'] == 'PAID').toList();
      } else {
        errorMessage = res['message'];
      }
    } catch (e) {
      errorMessage = 'Gagal memuat data tagihan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payBill(int billId, String method) async {
    isLoading = true;
    notifyListeners();
    try {
      final payload = {
        'bill_id': billId,
        'payment_method': method,
      };
      final res = await ApiService.post('${ApiConstants.baseUrl}/payments', payload);
      if (res['success'] == true) {
        await fetchCustomerBills();
        return true;
      }
      errorMessage = res['message'];
      return false;
    } catch (e) {
      errorMessage = '$e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}