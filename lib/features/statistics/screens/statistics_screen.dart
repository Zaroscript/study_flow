import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/category_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/utils/app_validators.dart';
import '../../common/providers/study_flow_state_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final today = DateTime.now().toIso8601String().split('T').first;
    final days = List.generate(
      7,
      (index) => DateTime.now().subtract(Duration(days: 6 - index)),
    );
    final counts = days
        .map(
          (day) => tasks
              .where(
                (task) =>
                    task.completed &&
                    task.date == day.toIso8601String().split('T').first,
              )
              .length,
        )
        .toList();
    final maximum = counts.fold<int>(
      1,
      (previous, value) => value > previous ? value : previous,
    );
    final distribution = <String, int>{};
    for (final task in tasks.where((task) => task.date == today)) {
      if (!AppValidators.validTimeRange(task.startTime, task.endTime)) continue;
      int minute(String value) =>
          int.parse(value.substring(0, 2)) * 60 + int.parse(value.substring(3));
      distribution.update(
        task.category,
        (value) => value + minute(task.endTime) - minute(task.startTime),
        ifAbsent: () => minute(task.endTime) - minute(task.startTime),
      );
    }
    const weekdays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const PageHeader(
          title: 'الإحصائيات',
          description:
              'بيانات من مهامك الفعلية تساعدك على التخطيط للخطوة التالية.',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'المهام المكتملة خلال أسبوع',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              const Text('تُجمع المهام حسب اليوم المحدد لها في المخطط.'),
              const SizedBox(height: 20),
              ...List.generate(
                7,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(weekdays[days[index].weekday - 1]),
                          ),
                          Text('${counts[index]} مهام'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: counts[index] / maximum,
                        minHeight: 8,
                        semanticsLabel:
                            '${weekdays[days[index].weekday - 1]}: مهام مكتملة',
                        semanticsValue: '${counts[index]}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'توزيع الوقت المخطط اليوم',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'هذه أوقات مجدولة في المخطط، وليست قياسًا لوقت التركيز الفعلي.',
              ),
              const SizedBox(height: 16),
              if (distribution.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('أضف أوقاتًا لمهام اليوم ليظهر توزيع وقتك هنا.'),
                ),
              ...distribution.entries.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.schedule,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(CategoryConstants.getLabel(item.key)),
                  trailing: Text('${item.value} دقيقة'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
