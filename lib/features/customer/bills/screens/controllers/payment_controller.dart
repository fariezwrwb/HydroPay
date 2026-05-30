import 'package:flutter/material.dart';

class PaymentModel extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _paymentDetails = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get paymentDetails => _paymentDetails;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> processPayment() async {
    setLoading(true);
    _errorMessage = '';
    
    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _errorMessage = 'Gagal memproses pembayaran: $e';
    } finally {
      setLoading(false);
    }
  }
}