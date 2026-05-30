import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/services/auth_service.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/admin/services/controllers/service_controller.dart';
import 'features/admin/customers/controllers/customer_controller.dart';
import 'features/admin/dashboard/controllers/admin_dashboard_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => AdminDashboardController()),
      ],
      child: MaterialApp(
        title: 'PDAM App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          useMaterial3: true,
        ),
        home: const SplashRouter(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

/// SplashRouter — cek session dulu, baru tentukan halaman awal
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getRole();

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 800));

    if (token != null && token.isNotEmpty && role != null) {
      if (role == 'ADMIN') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.customerDashboard);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8D4F5),
              Color(0xFFD6E8FB),
              Color(0xFFEEF5FD),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop_rounded,
                size: 72,
                color: Color(0xFF2563EB),
              ),
              SizedBox(height: 16),
              Text(
                'HydroPay',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B2A),
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tagihan Air Digital',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A7A99),
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                color: Color(0xFF2563EB),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}