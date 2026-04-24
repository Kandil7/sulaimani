import 'package:go_router/go_router.dart';
import '../../presentation/layout/main_layout.dart';
import '../../presentation/dashboard/pages/dashboard_page.dart';
import '../../presentation/products/pages/products_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsPage(),
          ),
        ],
      ),
    ],
  );
}
