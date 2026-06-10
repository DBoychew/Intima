import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/calendar/calendar_screen.dart';
import 'features/diary/diary_editor_screen.dart';
import 'features/diary/diary_entry.dart';
import 'features/diary/diary_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'shell.dart';
import 'theme/app_theme.dart';

void main() => runApp(const IntimaApp());

final _router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/diary',
            builder: (context, state) => const DiaryScreen(),
            routes: [
              GoRoute(
                  path: 'new',
                  builder: (context, state) => DiaryEditorScreen(
                      initial: state.extra as DiaryEntry?)),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen()),
        ]),
      ],
    ),
  ],
);

class IntimaApp extends StatelessWidget {
  const IntimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Intima',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
