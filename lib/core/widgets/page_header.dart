import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;
  const PageHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(context.tr(title), style: theme.textTheme.headlineSmall),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            context.tr(description!),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 540 ||
              MediaQuery.textScalerOf(context).scale(16) > 20;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                if (action != null) ...[const SizedBox(height: 16), action!],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: heading),
              if (action != null) ...[const SizedBox(width: 20), action!],
            ],
          );
        },
      ),
    );
  }
}
