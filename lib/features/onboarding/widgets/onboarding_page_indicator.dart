import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// An animated dot indicator where the active dot stretches into a sleek gradient pill.
class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final ValueChanged<int>? onDotTapped;

  const OnboardingPageIndicator({
    Key? key,
    required this.count,
    required this.currentIndex,
    this.onDotTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return GestureDetector(
          onTap: onDotTapped != null ? () => onDotTapped!(index) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isActive ? 28 : 8,
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    )
                  : null,
              color: isActive ? null : AppColors.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
