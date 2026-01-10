import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/network/network_info.dart';

// Auth
import '../data/datasources/local/auth_local_datasource.dart';
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/auth/check_auth_status_usecase.dart';
import '../domain/usecases/auth/get_cached_user_usecase.dart';
import '../domain/usecases/auth/get_profile_usecase.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/auth/update_profile_usecase.dart';
import '../presentation/bloc/auth/auth_bloc.dart';

// Product
import '../data/datasources/remote/product_remote_datasource.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/usecases/product/get_product_detail_usecase.dart';
import '../domain/usecases/product/get_products_usecase.dart';
import '../presentation/bloc/product/product_bloc.dart';

// Transaction
import '../data/datasources/remote/transaction_remote_datasource.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/transaction/create_transaction.dart';
import '../domain/usecases/transaction/get_sales_transactions.dart';
import '../domain/usecases/transaction/get_transaction_detail.dart';
import '../domain/usecases/transaction/get_transactions.dart';
import '../presentation/bloc/cart/cart_bloc.dart';
import '../presentation/bloc/transaction/transaction_bloc.dart';

// Stock
import '../data/datasources/remote/stock_remote_datasource.dart';
import '../data/repositories/stock_repository_impl.dart';
import '../domain/repositories/stock_repository.dart';
import '../domain/usecases/stock/get_low_stocks_usecase.dart';
import '../domain/usecases/stock/get_stock_by_product_usecase.dart';
import '../domain/usecases/stock/get_stocks_usecase.dart';
// Update Stock - DISABLED: API only supports GET operations
// import '../domain/usecases/stock/update_stock_usecase.dart';
import '../presentation/bloc/stock/stock_bloc.dart';

// Area
import '../data/datasources/remote/area_remote_datasource.dart';
import '../data/repositories/area_repository_impl.dart';
import '../domain/repositories/area_repository.dart';
import '../domain/usecases/area/get_areas.dart';
import '../domain/usecases/area/get_area_by_id.dart';
import '../presentation/bloc/area/area_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ========= EXTERNAL =========
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      ));
  
  sl.registerLazySingleton(() => Connectivity());

  // ========= CORE =========
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<FlutterSecureStorage>()),
  );

  // ========= DATA SOURCES =========
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<FlutterSecureStorage>()),
  );

  // Product
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Transaction
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Stock
  sl.registerLazySingleton<StockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Area
  sl.registerLazySingleton<AreaRemoteDataSource>(
    () => AreaRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // ========= REPOSITORIES =========
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl<ProductRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: sl<TransactionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(
      remoteDataSource: sl<StockRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<AreaRepository>(
    () => AreaRepositoryImpl(sl<AreaRemoteDataSource>()),
  );

  // ========= USE CASES =========
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl<AuthRepository>()));

  // Product
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetProductDetailUseCase(sl<ProductRepository>()));

  // Transaction
  sl.registerLazySingleton(() => GetTransactions(sl<TransactionRepository>()));
  sl.registerLazySingleton(() => GetTransactionDetail(sl<TransactionRepository>()));
  sl.registerLazySingleton(() => GetSalesTransactions(sl<TransactionRepository>()));
  sl.registerLazySingleton(() => CreateTransaction(sl<TransactionRepository>()));

  // Stock
  sl.registerLazySingleton(() => GetStocksUseCase(sl<StockRepository>()));
  sl.registerLazySingleton(() => GetLowStocksUseCase(sl<StockRepository>()));
  sl.registerLazySingleton(() => GetStockByProductUseCase(sl<StockRepository>()));

  // Area
  sl.registerLazySingleton(() => GetAreas(sl<AreaRepository>()));
  sl.registerLazySingleton(() => GetAreaById(sl<AreaRepository>()));

  // ========= BLOCS =========
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getProfileUseCase: sl<GetProfileUseCase>(),
      updateProfileUseCase: sl<UpdateProfileUseCase>(),
      checkAuthStatusUseCase: sl<CheckAuthStatusUseCase>(),
      getCachedUserUseCase: sl<GetCachedUserUseCase>(),
    ),
  );

  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl<GetProductsUseCase>(),
      getProductDetailUseCase: sl<GetProductDetailUseCase>(),
    ),
  );

  sl.registerFactory(
    () => TransactionBloc(
      getTransactions: sl<GetTransactions>(),
      getTransactionDetail: sl<GetTransactionDetail>(),
      getSalesTransactions: sl<GetSalesTransactions>(),
    ),
  );

  sl.registerFactory(
    () => CartBloc(
      createTransaction: sl<CreateTransaction>(),
    ),
  );

  sl.registerFactory(
    () => StockBloc(
      getStocksUseCase: sl<GetStocksUseCase>(),
      getLowStocksUseCase: sl<GetLowStocksUseCase>(),
      getStockByProductUseCase: sl<GetStockByProductUseCase>(),
      repository: sl<StockRepository>(),
    ),
  );

  sl.registerFactory(
    () => AreaBloc(
      getAreas: sl<GetAreas>(),
      getAreaById: sl<GetAreaById>(),
    ),
  );
}
