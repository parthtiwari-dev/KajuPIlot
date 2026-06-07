import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/deals/deals_screen.dart';
import '../../features/insights/insights_screen.dart';
import '../../features/money/money_screen.dart';
import '../../features/people/people_screen.dart';
import '../../features/people/party_history_screen.dart';
import '../../features/people/person_profile_screen.dart';
import '../../features/setup/setup_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/today/today_screen.dart';
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
            pageBuilder: (context, state) => _tabPage(
              state,
              const TodayScreen(),
            ),
          ),
          GoRoute(
            path: '/money',
            pageBuilder: (context, state) => _tabPage(
              state,
              const MoneyScreen(),
            ),
          ),
          GoRoute(
            path: '/deals',
            pageBuilder: (context, state) => _tabPage(
              state,
              const DealsScreen(),
            ),
          ),
          GoRoute(
            path: '/people',
            pageBuilder: (context, state) => _tabPage(
              state,
              const PeopleScreen(),
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => _tabPage(
              state,
              const InsightsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/people/:partyId',
        builder: (context, state) {
          return PersonProfileScreen(
            partyId: state.pathParameters['partyId']!,
          );
        },
      ),
      GoRoute(
        path: '/people/:partyId/history',
        builder: (context, state) {
          return PartyHistoryScreen(
            partyId: state.pathParameters['partyId']!,
          );
        },
      ),
    ],
  );
});

Page<void> _tabPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}

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
                Icons.store_outlined,
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
