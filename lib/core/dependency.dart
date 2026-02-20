import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/core/api.dart';
import 'package:pos/data/repository/reports_repo_impl.dart';
import 'package:pos/domain/repository/reports_repo.dart';
import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';
import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/data/datasource/auth_remote_datasource.dart';
import 'package:pos/data/datasource/sales_remote_datasource.dart';
import 'package:pos/data/datasource/inventory_datasource.dart';
import 'package:pos/data/datasource/crm_datasource.dart';
import 'package:pos/data/datasource/products_remote_datasource.dart';
import 'package:pos/data/datasource/purchase_remote_datasource.dart';
import 'package:pos/data/datasource/store_remote_datasource.dart';
import 'package:pos/data/datasource/reports_remote_datasource.dart';
import 'package:pos/data/repository/authenticating_user_impl.dart';
import 'package:pos/data/repository/crm_repo_impl.dart';
import 'package:pos/data/repository/dasboard_repo_impl.dart';
import 'package:pos/data/repository/industries_list_repo_impl.dart';
import 'package:pos/data/repository/inventory_repo_impl.dart';
import 'package:pos/data/repository/pos_profile_repo_impl.dart';
import 'package:pos/data/repository/products_repo_impl.dart';
import 'package:pos/data/repository/purchase_repo_impl.dart';
import 'package:pos/data/repository/register_company_repo_impl.dart';
import 'package:pos/data/repository/role_repo_imp.dart';
import 'package:pos/data/repository/sales_repository_impl.dart';
import 'package:pos/data/repository/store_repo_impl.dart';
import 'package:pos/data/repository/suppliers_repo_impl.dart';
import 'package:pos/data/repository/user_list_repo_impl.dart';
import 'package:pos/data/repository/user_register_repo_impl.dart';
import 'package:pos/domain/repository/abstract_sales_repository.dart';
import 'package:pos/domain/repository/authenticating_user_repo.dart';
import 'package:pos/domain/repository/crm_repo.dart';
import 'package:pos/domain/repository/dashboard_repo.dart';
import 'package:pos/domain/repository/industries_list_repo.dart';
import 'package:pos/domain/repository/inventory_repo.dart';
import 'package:pos/domain/repository/pos_profile_repo.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/domain/repository/purchase_repo.dart';
import 'package:pos/domain/repository/register_company_repo.dart';
import 'package:pos/domain/repository/register_user_repo.dart';
import 'package:pos/domain/repository/role_repo.dart';
import 'package:pos/domain/repository/store_repo.dart';
import 'package:pos/domain/repository/suppliers_repo.dart';
import 'package:pos/domain/repository/users_repo.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:pos/presentation/industries/bloc/industries_bloc.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/loginBloc/bloc/login_bloc.dart';
import 'package:pos/presentation/posProfile/bloc/pos_profile_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';
import 'package:pos/presentation/registerCompanyBloc/bloc/register_company_bloc.dart';
import 'package:pos/presentation/registerBloc/bloc/register_bloc.dart';
import 'package:pos/presentation/purchase_invoice/bloc/purchase_invoice_bloc.dart';
import 'package:pos/presentation/grn/bloc/grn_bloc.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/roles/bloc/role_bloc.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/presentation/barcode/bloc/barcode_bloc.dart';
import 'package:pos/presentation/price/bloc/price_bloc.dart';
import 'package:pos/presentation/units/bloc/units_bloc.dart';
import 'package:pos/presentation/brands/bloc/brands_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_bloc.dart';
import 'package:pos/presentation/price_list/bloc/price_list_bloc.dart';
import 'package:pos/presentation/warranties/bloc/warranties_bloc.dart';
import 'package:pos/presentation/invoices/bloc/invoices_bloc.dart';
import 'package:pos/presentation/sales/bloc/pos_opening_entries_bloc.dart';
import 'package:pos/data/datasource/subdomain_remote_datasource.dart';
import 'package:pos/domain/repository/subdomain_repository.dart';
import 'package:pos/data/repository/subdomain_repository_impl.dart';
import 'package:pos/presentation/subdomainBloc/subdomain_bloc.dart';

final getIt = GetIt.instance;

void setUp() {
  // ApiClient (creates Dio internally)
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Dio from ApiClient
  getIt.registerLazySingleton<Dio>(() => getIt<ApiClient>().dio);

  getIt.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSource(getIt<Dio>(), getIt<StorageService>()),
  );

  // Offline Support
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSource());

  // Repositories
  getIt.registerLazySingleton<RegisterRepository>(
    () => UserRegisterRepoImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  getIt.registerLazySingleton<RegisterCompanyRepo>(
    () => RegisterCompanyRepoImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<AuthenticateUserRepo>(
    () => AuthenticateUserRepoImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<UserListRepo>(
    () => UserListRepoImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      localDataSource: getIt<LocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<IndustriesRepo>(
    () => IndustriesListRepoImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<CrmRemoteDataSource>(
    () => CrmRemoteDataSource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSource(getIt<Dio>(), getIt<StorageService>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      getIt<Dio>(),
      inventoryRemoteDataSource: getIt<InventoryRemoteDataSource>(),
      storageService: getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<SalesRemoteDataSource>(
    () => SalesRemoteDataSource(getIt<Dio>(), getIt<StorageService>()),
  );

  getIt.registerLazySingleton<PurchaseRemoteDataSource>(
    () => PurchaseRemoteDataSource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ProductsRepo>(
    () => ProductsRepoImpl(
      productsRemoteDataSource: getIt<ProductsRemoteDataSource>(),
      remoteDataSource: getIt<RemoteDataSource>(),
      inventoryRemoteDataSource: getIt<InventoryRemoteDataSource>(),
      salesRemoteDataSource: getIt<SalesRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      localDataSource: getIt<LocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<CrmRepo>(
    () => CrmRepoImpl(
      remoteDataSource: getIt<CrmRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      localDataSource: getIt<LocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<StoreRepo>(
    () => StoreRepoImpl(
      remoteDataSource: getIt<StoreRemoteDataSource>(),
      inventoryRemoteDataSource: getIt<InventoryRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      localDataSource: getIt<LocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<RoleRepo>(
    () => RoleRepoImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );
  getIt.registerLazySingleton<PosProfileRepo>(
    () => PosProfileRepoImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );
  getIt.registerLazySingleton<DashboardRepo>(
    () => DashboardRepoImpl(
      remoteDataSource: getIt<SalesRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      localDataSource: getIt<LocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<InventoryRepo>(
    () => InventoryRepoImpl(
      remoteDataSource: getIt<InventoryRemoteDataSource>(),
      crmRemoteDataSource: getIt<CrmRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      localDataSource: getIt<LocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(
      dataSource: getIt<SalesRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      localDataSource: getIt<LocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<SuppliersRepo>(
    () => SuppliersRepoImpl(purchaseRemoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<PurchaseRepo>(
    () => PurchaseRepoImpl(purchaseRemoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<ReportsRepo>(
    () => ReportsRepoImpl(remoteDataSource: getIt<ReportsRemoteDataSource>()),
  );

  // Blocs
  getIt.registerFactory(() => RegisterBloc(registerRepository: getIt()));
  getIt.registerFactory(() => LoginBloc(authenticateUserRepo: getIt()));
  getIt.registerFactory(() => StaffBloc(userListRepo: getIt()));
  getIt.registerFactory(() => CrmBloc(crmRepo: getIt()));
  getIt.registerFactory(() => StoreBloc(storeRepo: getIt()));

  getIt.registerFactory(
    () => RegisterCompanyBloc(registerCompanyRepo: getIt()),
  );
  getIt.registerFactory(() => IndustriesBloc(industriesRepo: getIt()));
  getIt.registerFactory(() => ProductsBloc(productsRepo: getIt()));
  getIt.registerFactory(() => RoleBloc(roleRepo: getIt()));
  getIt.registerFactory(() => PosProfileBloc(posProfileRepo: getIt()));
  getIt.registerFactory(() => DashboardBloc(dashboardRepo: getIt()));
  getIt.registerFactory(() => InventoryBloc(inventoryRepo: getIt()));
  getIt.registerFactory(
    () => SalesBloc(
      salesRepository: getIt<SalesRepository>(),
      storageService: getIt<StorageService>(),
    ),
  );
  getIt.registerFactory(() => SuppliersBloc(suppliersRepo: getIt()));
  getIt.registerFactory(() => PurchaseBloc(purchaseRepo: getIt()));
  getIt.registerFactory(() => ReportsBloc(reportsRepo: getIt()));
  getIt.registerFactory(() => BarcodeBloc(productsRepo: getIt()));
  getIt.registerFactory(() => PriceBloc(productsRepo: getIt()));
  getIt.registerFactory(() => UnitsBloc(productsRepo: getIt()));
  getIt.registerFactory(() => BrandsBloc(productsRepo: getIt()));
  getIt.registerFactory(() => CategoriesBloc(productsRepo: getIt()));
  getIt.registerFactory(() => PriceListBloc(productsRepo: getIt()));
  getIt.registerFactory(() => WarrantiesBloc(productsRepo: getIt()));
  getIt.registerFactory(() => PurchaseInvoiceBloc(purchaseRepo: getIt()));
  getIt.registerFactory(() => GrnBloc(purchaseRepo: getIt()));
  getIt.registerFactory(() => InvoicesBloc(productsRepo: getIt()));
  getIt.registerFactory(() => PosOpeningEntriesBloc(productsRepo: getIt()));

  // Subdomain
  getIt.registerLazySingleton<SubdomainRemoteDataSource>(
    () => SubdomainRemoteDataSource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<SubdomainRepository>(
    () => SubdomainRepositoryImpl(
      remoteDataSource: getIt<SubdomainRemoteDataSource>(),
    ),
  );
  getIt.registerFactory(() => SubdomainBloc(subdomainRepository: getIt()));
}
