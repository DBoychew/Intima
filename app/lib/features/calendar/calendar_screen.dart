import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'quick_log_sheet.dart';

/// Прототип с примерни данни — реалните идват от БД във Фаза 3.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  static const _periodDays = {3, 4, 5, 6, 7};
  static const _intimacyDays = {17, 28};
  static const _fertileDays = {19, 20, 21};
  static const _today = 30;
  static const _daysInMonth = 30;
  static const _firstWeekday = 1; // 1 юни 2026 е понеделник

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Юни 2026'),
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuickLogSheet(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _weekdayHeader(context),
          const SizedBox(height: 8),
          _monthGrid(context),
          const SizedBox(height: 16),
          _legend(context),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Днес · 30 юни',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Настроение: 🙂', style: TextStyle(fontSize: 15)),
                      const Spacer(),
                      Text('Енергия ', style: Theme.of(context).textTheme.labelMedium),
                      const Icon(Icons.bolt, color: AppColors.accent, size: 18),
                      const Icon(Icons.bolt, color: AppColors.accent, size: 18),
                      const Icon(Icons.bolt, color: AppColors.surfaceHigh, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Следващ цикъл — около 24 юли',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _weekdayHeader(BuildContext context) {
    const days = ['П', 'В', 'С', 'Ч', 'П', 'С', 'Н'];
    return Row(
      children: [
        for (final d in days)
          Expanded(
            child: Center(
              child: Text(d, style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
      ],
    );
  }

  Widget _monthGrid(BuildContext context) {
    final cells = <Widget>[];
    for (var i = 1; i < _firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= _daysInMonth; day++) {
      cells.add(_DayCell(
        day: day,
        isToday: day == _today,
        isPeriod: _periodDays.contains(day),
        isIntimacy: _intimacyDays.contains(day),
        isFertile: _fertileDays.contains(day),
      ));
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  Widget _legend(BuildContext context) {
    Widget item(Color color, String label, {bool heart = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            heart
                ? const Icon(Icons.favorite, color: AppColors.intimacy, size: 12)
                : Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        );
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        item(AppColors.period, 'Менструация'),
        item(AppColors.intimacy, 'Интимност', heart: true),
        item(AppColors.fertile, 'Фертилни дни'),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isPeriod,
    required this.isIntimacy,
    required this.isFertile,
  });

  final int day;
  final bool isToday;
  final bool isPeriod;
  final bool isIntimacy;
  final bool isFertile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFertile
              ? AppColors.fertile.withValues(alpha: 0.18)
              : null,
          border: isToday
              ? Border.all(color: AppColors.primarySoft, width: 2)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text('$day', style: const TextStyle(fontSize: 14)),
            if (isPeriod)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.period, shape: BoxShape.circle),
                ),
              ),
            if (isIntimacy)
              const Positioned(
                top: 2,
                right: 2,
                child:
                    Icon(Icons.favorite, color: AppColors.intimacy, size: 11),
              ),
          ],
        ),
      ),
    );
  }
}
