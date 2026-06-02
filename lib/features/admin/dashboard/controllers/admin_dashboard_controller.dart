import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';

class AdminDashboardController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  
  int customerCount = 0;
  int serviceCount = 0;
  int unverifiedPaymentCount = 0;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadCustomerCount(),
        _loadServiceCount(),
        _loadUnverifiedPayments(),
      ]);
    } catch (e) {
      errorMessage = 'Gagal memuat data dashboard';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> _loadCustomerCount() async {
    try {
      final res = await ApiService.get(
        ApiConstants.customers,
        withToken: true,
      );
      if (res['success'] == true) {
        customerCount = res['count'] ?? 0;
      }
    } catch (_) {
      customerCount = 0;
    }
  }

 
  Future<void> _loadServiceCount() async {
    try {
      final res = await ApiService.get(
        ApiConstants.services,
        withToken: true,
      );
      if (res['success'] == true) {
        serviceCount = res['count'] ?? 0;
      }
    } catch (_) {
      serviceCount = 0;
    }
  }

 
  Future<void> _loadUnverifiedPayments() async {
    try {
      final res = await ApiService.get(
        ApiConstants.payments,
        withToken: true,
      );
      if (res['success'] == true) {
        final data = res['data'] as List<dynamic>? ?? [];
        unverifiedPaymentCount =
            data.where((p) => p['verified'] == false).length;
      }
    } catch (_) {
      unverifiedPaymentCount = 0;
    }
  }
}