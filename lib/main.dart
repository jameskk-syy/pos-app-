import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:pos/presentation/industries/bloc/industries_bloc.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/loginBloc/bloc/login_bloc.dart';
import 'package:pos/presentation/posProfile/bloc/pos_profile_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';
import 'package:pos/presentation/registerCompanyBloc/bloc/register_company_bloc.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/roles/bloc/role_bloc.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/screens/splash_screen.dart';
import 'package:pos/presentation/registerBloc/bloc/register_bloc.dart';
import 'package:pos/presentation/warranties/bloc/warranties_bloc.dart';
import 'package:pos/utils/themes/app_theme.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  setUp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterBloc>(create: (_) => getIt<RegisterBloc>()),
        BlocProvider<RegisterCompanyBloc>(
          create: (_) => getIt<RegisterCompanyBloc>(),
        ),
        BlocProvider<LoginBloc>(create: (_) => getIt<LoginBloc>()),
        BlocProvider<StaffBloc>(create: (_) => getIt<StaffBloc>()),
        BlocProvider<IndustriesBloc>(create: (_) => getIt<IndustriesBloc>()),
        BlocProvider<ProductsBloc>(create: (_) => getIt<ProductsBloc>()),
        BlocProvider<CrmBloc>(create: (_) => getIt<CrmBloc>()),
        BlocProvider<StoreBloc>(create: (_) => getIt<StoreBloc>()),
        BlocProvider<RoleBloc>(create: (_) => getIt<RoleBloc>()),
        BlocProvider<PosProfileBloc>(create: (_) => getIt<PosProfileBloc>()),
        BlocProvider<DashboardBloc>(create: (_) => getIt<DashboardBloc>()),
        BlocProvider<InventoryBloc>(create: (_) => getIt<InventoryBloc>()),
        BlocProvider<SalesBloc>(create: (_) => getIt<SalesBloc>()),
        BlocProvider<SuppliersBloc>(create: (_) => getIt<SuppliersBloc>()),
        BlocProvider<PurchaseBloc>(create: (_) => getIt<PurchaseBloc>()),
        BlocProvider<ReportsBloc>(create: (_) => getIt<ReportsBloc>()),
        BlocProvider<WarrantiesBloc>(create: (_) => getIt<WarrantiesBloc>()),
        // add other blocs here if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme().init(),
        home: const SplashScreen(),
      ),
    );
  }
}
