import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';

class CustomerDashboardController extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';
  List<dynamic> bills = [];
  int unpaidCount = 0;
  Map<String, dynamic>? profile;

  Future<void> fetchDashboardData() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      
      final results = await Future.wait([
        ApiService.get(ApiConstants.myBills),
        ApiService.get(ApiConstants.customerMe),
      ]);

      final billsRes = results[0];
      final profileRes = results[1];

      if (billsRes['success'] == true) {
        bills = billsRes['data'] ?? [];
        unpaidCount = bills.where((b) => b['paid'] == false).length;
      }

      if (profileRes['success'] == true) {
        profile = profileRes['data'];
      }
    } catch (e) {
      errorMessage = 'Gagal memuat data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}