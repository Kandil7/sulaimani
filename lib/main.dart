import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/backup_scheduler.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/alerts/bloc/alerts_bloc.dart';
import 'presentation/alerts/bloc/alerts_event.dart';
import 'presentation/dashboard/bloc/dashboard_bloc.dart';
import 'presentation/dashboard/bloc/dashboard_event.dart';
import 'presentation/settings/bloc/settings_bloc.dart';
import 'presentation/settings/bloc/settings_event.dart';
import 'presentation/settings/bloc/settings_state.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final BackupScheduler _backupScheduler;

  @override
  void initState() {
    super.initState();
    _backupScheduler = BackupScheduler();
    // Start backup scheduler with settings repository
    _backupScheduler.start(
      settingsRepository: di.sl<SettingsRepository>(),
    );
  }

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
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>()..add(LoadSettings()),
        ),
      ],
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            // Sync backup scheduler with settings changes
            if (state.settings.autoBackupEnabled) {
              _backupScheduler.start(
                settingsRepository: di.sl<SettingsRepository>(),
              );
            } else {
              _backupScheduler.stop();
            }
          }
        },
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
      ),
    );
  }
}
