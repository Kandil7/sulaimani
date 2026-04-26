import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/alerts/bloc/alerts_bloc.dart';
import 'presentation/alerts/bloc/alerts_event.dart';
import 'presentation/dashboard/bloc/dashboard_bloc.dart';
import 'presentation/dashboard/bloc/dashboard_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Configure window manager
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(1024, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'صيدلية السليماني — نظام إدارة الصيدلية',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AlertsBloc>(
          create: (_) => di.sl<AlertsBloc>()..add(LoadAlerts()),
        ),
        BlocProvider<DashboardBloc>(
          create: (_) => di.sl<DashboardBloc>()..add(LoadDashboard()),
        ),
      ],
      child: MaterialApp.router(
        title: 'صيدلية السليماني',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,

        // Localization
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'EG'), // Arabic, Egypt
        ],
        locale: const Locale('ar', 'EG'), // Default to Arabic

        // Routing
        routerConfig: AppRouter.router,
      ),
    );
  }
}
