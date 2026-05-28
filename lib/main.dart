import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/admin/services/controllers/service_controller.dart';
import 'features/admin/customers/controllers/customer_controller.dart';
import 'core/services/auth_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthService.saveOwnerToken('cede99000e4669efd1c71a60e189ac61db29db03');


  await AuthService.saveSession(
    token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEzNiwicm9sZSI6IkFETUlOIiwiaWF0IjoxNzc5OTY3NTUwLCJleHAiOjE3ODAwNTM5NTB9.gLFONgYeGr-h9dFsM-Kh9EiRQ7OQDdg3-UEU1rK9lfA',
    role: 'ADMIN',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ServiceController()),
        ChangeNotifierProvider(create: (_) => CustomerController()),
      ],
      child: MaterialApp(
        title: 'PDAM App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.adminProfile,
        routes: AppRoutes.routes,
      ),
    );
  }
}