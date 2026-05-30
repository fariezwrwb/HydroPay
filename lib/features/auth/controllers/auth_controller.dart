import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/api_constants.dart';
import '../models/auth_model.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> register({
    required String username,
    required String password,
    required String name,
    required String phone,
    String role = 'ADMIN', 
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
    
      if (role == 'CUSTOMER') {
        errorMessage = 'Akun customer dibuat oleh Admin. Silakan login.';
        return false;
      }

      final res = await ApiService.post(
        ApiConstants.register, 
        {
          'username': username,
          'password': password,
          'name': name,
          'phone': phone,
        },
      );

      if (res['success'] == true) {
        final ownerToken = res['data']['owner_token'] ?? '';
        await AuthService.saveOwnerToken(ownerToken);
        return true;
      } else {
        errorMessage = res['message'] ?? 'Registrasi gagal';
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

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post(
        ApiConstants.login,
        {'username': username, 'password': password},
      );

      if (res['success'] == true) {
        final auth = AuthResponse.fromJson(res);
        await AuthService.saveSession(token: auth.token, role: auth.role);
        return auth.role; 
      } else {
        errorMessage = res['message'] ?? 'Login gagal';
        return null;
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    notifyListeners();
  }
}