import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/constants/api_constants.dart';
import '../models/service_model.dart';

class ServiceController extends ChangeNotifier {
  List<ServiceModel> services = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.get(ApiConstants.services);
      if (res['success'] == true) {
        services = (res['data'] as List)
            .map((e) => ServiceModel.fromJson(e))
            .toList();
      } else {
        errorMessage = res['message'];
      }
    } catch (e) {
      errorMessage = 'Gagal memuat layanan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post(ApiConstants.bills, payload);
      if (res['success'] == true) {
        await fetchAll();
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

  Future<bool> update(int id, Map<String, dynamic> payload) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.patch('${ApiConstants.bills}/$id', payload);
      if (res['success'] == true) {
        await fetchAll();
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

  Future<bool> delete(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.delete('${ApiConstants.bills}/$id');
      if (res['success'] == true) {
        await fetchAll();
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