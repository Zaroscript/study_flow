import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';

/// A polished, GPU-accelerated pulsing emblem with radial glows and floating particles,
/// respecting reduced-motion accessibility settings.
class AnimatedPulseEmblem extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color primaryColor;
  final Color accentColor;

  const AnimatedPulseEmblem({
    super.key,
    required this.icon,
    this.size = 110,
    this.primaryColor = AppColors.primary,
    this.accentColor = AppColors.secondary,
  });

  @override
  State<AnimatedPulseEmblem> createState() => _AnimatedPulseEmblemState();
}

class _AnimatedPulseEmblemState extends State<AnimatedPulseEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context)) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);

    if (reduceMotion) {
      return _buildEmblemContent(1.0);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildEmblemContent(_glowAnimation.value);
      },
    );
  }

  Widget _buildEmblemContent(double scale) {
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer atmospheric glow
          Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size * 1.35,
              height: widget.size * 1.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.primaryColor.withValues(alpha: 0.35),
                    widget.accentColor.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // Secondary subtle soft halo
          Container(
            width: widget.size * 1.08,
            height: widget.size * 1.08,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.primaryColor.withValues(alpha: 0.08),
              border: Border.all(
                color: widget.primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),

          // Central core shield
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.primaryColor,
                  widget.primaryColor.withValues(alpha: 0.85),
                  widget.accentColor,
                ],
              ),
              borderRadius: BorderRadius.circular(widget.size * 0.32),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: widget.size * 0.48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
