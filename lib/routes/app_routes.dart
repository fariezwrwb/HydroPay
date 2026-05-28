import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/admin/dashboard/screens/admin_dashboard_screen.dart';
import '../features/admin/services/screens/service_list_screen.dart';
import '../features/admin/customers/screens/customer_list_screen.dart';
import '../features/admin/bills/screens/bill_list_screen.dart';
import '../features/admin/profile/screen/admin_profile_screen.dart';
import '../features/customer/dashboard/screens/customer_dashboard_screen.dart';
import '../features/customer/bills/screens/my_bills_screen.dart';
import '../features/customer/profile/screens/customer_profile_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const adminDashboard = '/admin/dashboard';
  static const adminServices = '/admin/services';
  static const adminCustomers = '/admin/customers';
  static const adminBills = '/admin/bills';
  static const adminProfile = '/admin/profile';
  static const customerDashboard = '/customer/dashboard';
  static const customerBills = '/customer/bills';
  static const customerProfile = '/customer/profile';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        adminDashboard: (_) => const AdminDashboardScreen(),
        adminServices: (_) => const ServiceListScreen(),
        adminCustomers: (_) => const CustomerListScreen(),
        adminBills: (_) => const BillListScreen(),
        adminProfile: (_) => const AdminProfileScreen(),
        customerDashboard: (_) => const CustomerDashboardScreen(),
        customerBills: (_) => const MyBillsScreen(),
        customerProfile: (_) => const CustomerProfileScreen(),
      };
}