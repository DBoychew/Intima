import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'boot_screen.dart';
import 'data/cycle_prefs_repository.dart';
import 'data/database.dart';
import 'data/db_manager.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/diary/diary_editor_screen.dart';
import 'features/diary/diary_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'security/app_lock.dart';
import 'security/lock_screen.dart';
import 'security/secure_flag.dart';
import 'shell.dart';
import 'theme/app_theme.dart';

/// UI-ят тръгва веднага; инициализацията върви на BootScreen с видим
/// прогрес — замръзнал нативен splash вече не е възможен.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootSteps = [
    (label: 'Отключваме базата…', run: dbManager.open),
    (
      label: 'Зареждаме настройките…',
      run: () => CyclePrefsRepository(dbManager).hydrate(),
    ),
    (label: 'Проверяваме защитата…', run: appLock.init),
    (label: 'Скриваме следите…', run: SecureFlag.applyAtStartup),
  ];
  runApp(const IntimaApp());
}

final _router = GoRouter(
  initialLocation: '/boot',
  // Превключва моментално между /lock и приложението при (от)заключване.
  refreshListenable: appLock,
  redirect: (context, state) {
    // Boot екранът решава сам накъде да продължи.
    if (state.matchedLocation == '/boot') return null;
    final atLock = state.matchedLocation == '/lock';
    if (appLock.locked && !atLock) return '/lock';
    if (!appLock.locked && atLock) return '/calendar';
    return null;
  },
  routes: [
    GoRoute(
      path: '/boot',
      builder: (context, state) => const BootScreen(),
    ),
    GoRoute(
      path: '/lock',
      builder: (context, state) => const LockScreen(),
    ),
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
                      initial: state.extra as DiaryEntryRow?)),
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

class IntimaApp extends StatefulWidget {
  const IntimaApp({super.key});

  @override
  State<IntimaApp> createState() => _IntimaAppState();
}

class _IntimaAppState extends State<IntimaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Излизане от приложението → заключваме (ако има PIN).
    if (state == AppLifecycleState.paused) appLock.lock();
  }

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
