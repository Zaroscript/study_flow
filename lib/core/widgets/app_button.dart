import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/app_haptics.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 48,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    void submit() {
      final form = Form.maybeOf(context);
      if (form != null && !form.validate()) {
        AppHaptics.rejection();
        return;
      }
      AppHaptics.light();
      onPressed?.call();
    }

    final child = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(context.tr(text), textAlign: TextAlign.center),
              ),
            ],
          );
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(48, height)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.labelLarge),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    final callback = onPressed != null && !isLoading ? submit : null;
    final Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(style: style, onPressed: callback, child: child);
        break;
      case AppButtonVariant.secondary:
        button = FilledButton.tonal(
          style: style,
          onPressed: callback,
          child: child,
        );
        break;
      case AppButtonVariant.outline:
        button = OutlinedButton(
          style: style,
          onPressed: callback,
          child: child,
        );
        break;
      case AppButtonVariant.ghost:
        button = TextButton(style: style, onPressed: callback, child: child);
        break;
      case AppButtonVariant.danger:
        button = FilledButton(
          style: style.copyWith(
            backgroundColor: WidgetStatePropertyAll(scheme.error),
            foregroundColor: WidgetStatePropertyAll(scheme.onError),
          ),
          onPressed: callback,
          child: child,
        );
        break;
    }
    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
