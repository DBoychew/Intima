import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      emoji: '🔒',
      title: 'Само твое.',
      body:
          'Всичко остава на телефона ти, криптирано.\nБез акаунт. Без облак. Без любопитни очи.',
    ),
    (
      emoji: '📅',
      title: 'Календар на близостта',
      body:
          'Цикъл, настроение, интимни моменти —\nвсичко на един дискретен екран.',
    ),
    (
      emoji: '📔',
      title: 'Дневник на близостта',
      body:
          'Записвай моментите, които искаш да запомниш.\nСамо за теб. Или за двама.',
    ),
  ];

  void _next() {
    if (_page == _pages.length - 1) {
      context.go('/calendar');
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 72)),
                        const SizedBox(height: 32),
                        Text(p.title,
                            style: Theme.of(context).textTheme.displaySmall,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(p.body,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.accent : AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _next,
                child: Text(last ? 'Започни' : 'Продължи'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
