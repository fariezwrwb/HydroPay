import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';

class AdminDashboardController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  
  int customerCount = 0;
  int serviceCount = 0;
  int unverifiedPaymentCount = 0;
  
  // Additional data for better UI
  double totalRevenue = 0;
  double outstandingAmount = 0;
  int totalBills = 0;
  int verifiedPaymentCount = 0;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadCustomerCount(),
        _loadServiceCount(),
        _loadUnverifiedPayments(),
        _loadAdditionalStats(),
      ]);
    } catch (e) {
      errorMessage = 'Gagal memuat data dashboard: ${e.toString()}';
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
    } catch (e) {
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
    } catch (e) {
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
        unverifiedPaymentCount = data.where((p) => p['verified'] == false).length;
        verifiedPaymentCount = data.where((p) => p['verified'] == true).length;
      }
    } catch (e) {
      unverifiedPaymentCount = 0;
      verifiedPaymentCount = 0;
    }
  }

  // Additional data for better UI
  Future<void> _loadAdditionalStats() async {
    try {
      final billsRes = await ApiService.get(
        ApiConstants.bills,
        withToken: true,
      );
      if (billsRes['success'] == true) {
        final bills = billsRes['data'] as List<dynamic>? ?? [];
        totalBills = bills.length;
        
        final paidBills = bills.where((b) => b['paid'] == true).toList();
        totalRevenue = paidBills.fold(0.0, (sum, bill) => sum + (bill['price'] ?? 0));
        
        final unpaidBills = bills.where((b) => b['paid'] == false).toList();
        outstandingAmount = unpaidBills.fold(0.0, (sum, bill) => sum + (bill['price'] ?? 0));
      }
    } catch (e) {
      totalRevenue = 0;
      outstandingAmount = 0;
      totalBills = 0;
    }
  }

  String formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}