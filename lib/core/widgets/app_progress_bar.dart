import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  final double progress; // between 0.0 and 1.0 (or percentage 0-100)
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const AppProgressBar({
    Key? key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Normalize progress to 0.0 - 1.0
    final normalized = progress.isFinite
        ? (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0)
              .toDouble()
        : 0.0;
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Semantics(
      label: 'التقدم',
      value: '${(normalized * 100).round()}%',
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: radius,
        ),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: normalized),
          builder: (context, animatedFactor, _) {
            return FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: animatedFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: color ?? theme.colorScheme.primary,
                  borderRadius: radius,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
