import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_provider.dart';

class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<String>(
    tooltip: 'Language / اللغة',
    initialValue: ref.watch(localeProvider).languageCode,
    onSelected: (code) async {
      await ref.read(localeProvider.notifier).setLanguage(code);
    },
    itemBuilder: (context) => const [
      PopupMenuItem(value: 'ar', child: Text('العربية')),
      PopupMenuItem(value: 'en', child: Text('English')),
    ],
    child: const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language),
          SizedBox(width: 8),
          Text('العربية / English'),
        ],
      ),
    ),
  );
}
