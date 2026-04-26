import 'package:go_router/go_router.dart';
import '../../presentation/layout/main_layout.dart';
import '../../presentation/dashboard/pages/dashboard_page.dart';
import '../../presentation/products/pages/products_page.dart';
import '../../presentation/pos/pages/pos_page.dart';
import '../../presentation/reports/pages/reports_page.dart';
import '../../presentation/settings/pages/settings_page.dart';
import '../../presentation/alerts/pages/alerts_page.dart';
import '../../presentation/customers/pages/customers_page.dart';
import '../../presentation/invoices/pages/invoices_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) {
              final preselectedId = state.uri.queryParameters['preselect'];
              return ProductsPage(
                  preselectedProductId: preselectedId != null
                      ? int.tryParse(preselectedId)
                      : null);
            },
          ),
          GoRoute(
            path: '/pos',
            builder: (context, state) => const PosPage(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomersPage(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/invoices',
            builder: (context, state) => const InvoicesPage(),
          ),
        ],
      ),
    ],
  );
}
