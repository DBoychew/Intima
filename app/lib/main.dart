import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'boot_screen.dart';
import 'core/cycle_settings.dart';
import 'core/demo_seed.dart';
import 'core/notifications.dart';
import 'core/premium.dart';
import 'core/theme_controller.dart';
import 'data/cycle_prefs_repository.dart';
import 'l10n/app_localizations.dart';
import 'data/database.dart';
import 'data/db_manager.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/diary/diary_editor_screen.dart';
import 'features/diary/diary_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'security/app_lock.dart';
import 'security/lock_screen.dart';
import 'security/secure_flag.dart';
import 'shell.dart';
import 'theme/app_theme.dart';

/// Език за тестове — null означава езика на устройството.
Locale? localeOverride;

/// За скрийншоти на конкретен език:
///   --dart-define=INTIMA_SCREENSHOTS=true --dart-define=INTIMA_LOCALE=bg
const _screenshotLocale = String.fromEnvironment('INTIMA_LOCALE');

/// UI-ят тръгва веднага; инициализацията върви на BootScreen с видим
/// прогрес — замръзнал нативен splash вече не е възможен.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (screenshotMode && _screenshotLocale.isNotEmpty) {
    localeOverride = Locale(_screenshotLocale);
  }
  bootSteps = [
    (label: (l) => l.bootDb, run: dbManager.open),
    (
      label: (l) => l.bootPrefs,
      run: () async {
        await CyclePrefsRepository(dbManager).hydrate();
        await premium.init();
        await themeController.init();
      },
    ),
    (label: (l) => l.bootLock, run: appLock.init),
    (label: (l) => l.bootSecure, run: SecureFlag.applyAtStartup),
    (
      label: (l) => l.bootNotifications,
      run: () async {
        await Notifications.init();
        await Notifications.syncCycleReminders();
        // Прогнозата мръдне ли (нов запис, друга дължина на цикъла) —
        // напомнянията се пренасрочват сами.
        cycleSettings.addListener(Notifications.syncCycleReminders);
      },
    ),
    if (screenshotMode)
      (
        label: (l) => l.bootStarting,
        run: () async {
          // Само за Play скрийншоти: снимки разрешени + demo данни;
          // INTIMA_THEME=light снима светлата тема (с Premium).
          await SecureFlag.set(false);
          await seedDemoData();
          if (const String.fromEnvironment('INTIMA_THEME') == 'light') {
            await premium.activate();
            await themeController.set(ThemeMode.light);
          }
        },
      ),
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
              path: '/insights',
              builder: (context, state) => const InsightsScreen()),
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
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp.router(
        title: 'Intima',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(themeController.palette.light),
        darkTheme: AppTheme.dark(themeController.palette.dark),
        themeMode: themeController.mode,
        locale: localeOverride,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
      ),
    );
  }
}
