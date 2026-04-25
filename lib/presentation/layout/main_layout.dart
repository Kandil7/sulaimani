import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/side_menu.dart';
import 'widgets/top_bar.dart';
import '../alerts/bloc/alerts_bloc.dart';
import '../alerts/bloc/alerts_state.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, alertsState) {
        final alertCount =
            alertsState is AlertsLoaded ? alertsState.totalCount : 0;

        return Scaffold(
          body: Row(
            children: [
              SideMenu(alertCount: alertCount),
              Expanded(
                child: Column(
                  children: [
                    const TopBar(),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
