import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/customer_model.dart';

class CustomerController extends ChangeNotifier {
  List<CustomerModel> customers = [];
  bool isLoading = false;
  String? errorMessage;
  int totalCount = 0;

  Future<void> fetchAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.get(ApiConstants.customers);
      if (res['success'] == true) {
        customers = (res['data'] as List)
            .map((e) => CustomerModel.fromJson(e))
            .toList();
        totalCount = res['count'] ?? customers.length;
      } else {
        errorMessage = res['message'] ?? 'Gagal memuat data customer';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String username,
    required String password,
    required String customerNumber,
    required String address,
    required int serviceId,
    required String name,
    required String phone,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.post(
        ApiConstants.customers,
        {
          'username': username,
          'password': password,
          'customer_number': customerNumber,
          'address': address,
          'service_id': serviceId,
          'name': name,
          'phone': phone,
        },
      );
      if (res['success'] == true) {
        await fetchAll();
        return true;
      }
      errorMessage = res['message'] ?? 'Gagal menambah customer';
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
    required String customerNumber,
    required String address,
    required int serviceId,
    required String name,
    required String phone,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.patch(
        '${ApiConstants.customers}/$id',
        {
          'customer_number': customerNumber,
          'address': address,
          'service_id': serviceId,
          'name': name,
          'phone': phone,
        },
      );
      if (res['success'] == true) {
        await fetchAll();
        return true;
      }
      errorMessage = res['message'] ?? 'Gagal mengupdate customer';
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
      final res =
          await ApiService.delete('${ApiConstants.customers}/$id');
      if (res['success'] == true) {
        await fetchAll();
        return true;
      }
      errorMessage = res['message'] ?? 'Gagal menghapus customer';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}