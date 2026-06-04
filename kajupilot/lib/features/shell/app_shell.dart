import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/kaju_colors.dart';
import '../input/universal_input_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const _tabs = [
    _ShellTab('Today', '/today', Icons.today_outlined, Key('nav-today')),
    _ShellTab('Money', '/money', Icons.currency_rupee, Key('nav-money')),
    _ShellTab('Deals', '/deals', Icons.inventory_2_outlined, Key('nav-deals')),
    _ShellTab('People', '/people', Icons.groups_2_outlined, Key('nav-people')),
    _ShellTab('More', '/more', Icons.more_horiz, Key('nav-more')),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _tabs.indexWhere((tab) => location == tab.path);
    final currentIndex = selectedIndex == -1 ? 0 : selectedIndex;
    final colors = context.kajuColors;

    return Scaffold(
      backgroundColor: colors.bgBase,
      body: SafeArea(
        bottom: false,
        child: child,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgBase,
          border: Border(top: BorderSide(color: colors.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const UniversalInputBar(),
              NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => context.go(_tabs[index].path),
                destinations: [
                  for (final tab in _tabs)
                    NavigationDestination(
                      key: tab.key,
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(tab.icon),
                      label: tab.label,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab(this.label, this.path, this.icon, this.key);

  final String label;
  final String path;
  final IconData icon;
  final Key key;
}
