import 'package:flutter/material.dart';
import 'widgets/side_menu.dart';
import 'widgets/top_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideMenu(),
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
  }
}
