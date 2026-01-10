import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../di/injection_container.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/area/area_bloc.dart';
import '../../presentation/bloc/cart/cart_bloc.dart';
import '../../presentation/bloc/product/product_bloc.dart';
import '../../presentation/bloc/stock/stock_bloc.dart';
import '../../presentation/bloc/transaction/transaction_bloc.dart';
import '../../presentation/pages/area/area_list_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/product/product_detail_page.dart';
import '../../presentation/pages/product/product_list_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/stock/stock_list_page.dart';
import '../../presentation/pages/transaction/transaction_detail_page.dart';
import '../../presentation/pages/transaction/transaction_form_page.dart';
import '../../presentation/pages/transaction/transaction_list_page.dart';

/// App Router Configuration
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  // Auth BLoC instance for routing
  static late AuthBloc _authBloc;
  
  static void init(AuthBloc authBloc) {
    _authBloc = authBloc;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: _guardRoute,
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<TransactionBloc>(),
          child: const HomePage(),
        ),
      ),

      // Stock
      GoRoute(
        path: '/stock',
        name: 'stock',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<StockBloc>(),
          child: const StockListPage(),
        ),
      ),

      // Products
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ProductBloc>(),
          child: const ProductListPage(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'product-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BlocProvider(
                create: (context) => sl<ProductBloc>(),
                child: ProductDetailPage(productId: id),
              );
            },
          ),
        ],
      ),

      // Transactions
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<TransactionBloc>(),
          child: const TransactionListPage(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: 'new-transaction',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => sl<CartBloc>()),
                BlocProvider(create: (context) => sl<ProductBloc>()),
              ],
              child: const TransactionFormPage(),
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'transaction-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BlocProvider(
                create: (context) => sl<TransactionBloc>(),
                child: TransactionDetailPage(transactionId: id),
              );
            },
          ),
        ],
      ),

      // Areas
      GoRoute(
        path: '/areas',
        name: 'areas',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AreaBloc>(),
          child: const AreaListPage(),
        ),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.uri.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Route guard for authentication
  static String? _guardRoute(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final isLoggedIn = authState.isAuthenticated;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    final isSplash = state.matchedLocation == '/splash';

    // Allow splash screen
    if (isSplash) return null;

    // If not logged in and trying to access protected route
    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    // If logged in and trying to access auth routes
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    return null;
  }
}

/// Route names constants
class Routes {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const home = 'home';
  static const profile = 'profile';
  static const editProfile = 'edit-profile';
  static const products = 'products';
  static const productDetail = 'product-detail';
  static const stock = 'stock';
  static const transactions = 'transactions';
  static const transactionDetail = 'transaction-detail';
  static const newTransaction = 'new-transaction';
  static const commissions = 'commissions';
  static const areas = 'areas';
}
