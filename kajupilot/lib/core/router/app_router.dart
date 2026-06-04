import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/setup/setup_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/shell/empty_feature_screen.dart';
import '../auth/auth_controller.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/today',
    redirect: (context, state) {
      final path = state.uri.path;

      if (authState.isLoading) {
        return path == '/splash' ? null : '/splash';
      }

      final isSignedIn = authState.valueOrNull != null;
      if (!isSignedIn) {
        return path == '/setup' ? null : '/setup';
      }

      if (path == '/' || path == '/setup' || path == '/splash') {
        return '/today';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const KajuSplashScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const KajuSplashScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/today',
            builder: (context, state) => const EmptyFeatureScreen(
              key: Key('feature-today-screen'),
              title: 'Today',
              eyebrow: 'Friday command center',
              body: 'Nothing on the agenda yet.',
              icon: Icons.today_outlined,
            ),
          ),
          GoRoute(
            path: '/money',
            builder: (context, state) => const EmptyFeatureScreen(
              key: Key('feature-money-screen'),
              title: 'Money',
              eyebrow: 'Receivable, payable, expenses',
              body: 'Ledgers will appear here once entries begin.',
              icon: Icons.currency_rupee,
            ),
          ),
          GoRoute(
            path: '/deals',
            builder: (context, state) => const EmptyFeatureScreen(
              key: Key('feature-deals-screen'),
              title: 'Deals',
              eyebrow: 'Sales and purchases',
              body: 'Deal cards will live here after manual entry starts.',
              icon: Icons.inventory_2_outlined,
            ),
          ),
          GoRoute(
            path: '/people',
            builder: (context, state) => const EmptyFeatureScreen(
              key: Key('feature-people-screen'),
              title: 'People',
              eyebrow: 'Customers and suppliers',
              body: 'Contacts and trust tags will appear here.',
              icon: Icons.groups_2_outlined,
            ),
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => const EmptyFeatureScreen(
              key: Key('feature-more-screen'),
              title: 'More',
              eyebrow: 'Insights and settings',
              body: 'Reports, theme controls, and admin links come later.',
              icon: Icons.more_horiz,
            ),
          ),
        ],
      ),
    ],
  );
});

class KajuSplashScreen extends StatelessWidget {
  const KajuSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.spa_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text('KajuPilot', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
