import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';

/// Custom clipper that extracts the top half of a card [0, height / 2].
class TopCardClipper extends CustomClipper<Rect> {
  const TopCardClipper();

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, size.height / 2);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

/// Custom clipper that extracts the bottom half of a card [height / 2, height].
class BottomCardClipper extends CustomClipper<Rect> {
  const BottomCardClipper();

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

/// Individual 3D Split-Flap Digit Card with authentic mechanical perspective,
/// custom clipping, hinge line, and dynamic light shading.
class FlipCardDigit extends StatefulWidget {
  final int digit;
  final double width;
  final double height;

  const FlipCardDigit({
    Key? key,
    required this.digit,
    this.width = 52.0,
    this.height = 84.0,
  }) : super(key: key);

  @override
  State<FlipCardDigit> createState() => _FlipCardDigitState();
}

class _FlipCardDigitState extends State<FlipCardDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentDigit = 0;
  int _oldDigit = 0;

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _oldDigit = widget.digit;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _oldDigit = _currentDigit;
        });
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlipCardDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != _currentDigit) {
      _oldDigit = _currentDigit;
      _currentDigit = widget.digit;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHalfCard({
    required int digit,
    required double width,
    required double height,
    required bool isTop,
    required double shadowOpacity,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isTop
              ? const [Color(0xFF222D42), Color(0xFF172032)]
              : const [Color(0xFF131B29), Color(0xFF0D131F)],
        ),
        border: Border.all(
          color: const Color(0x1FFFFFFF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Centered digit text
          Center(
            child: Text(
              '$digit',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: height * 0.58,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFF8FAFC),
                letterSpacing: -1.0,
                height: 1.0,
              ),
            ),
          ),
          // Subtle top bevel highlight for top half
          if (isTop)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 1,
              child: Container(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          // Subtle bottom shadow for bottom half
          if (!isTop)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 1,
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          // Dynamic lighting / shading overlay during flip
          if (shadowOpacity > 0.0)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(shadowOpacity),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width;
    final height = widget.height;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated 3D split flaps
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final t = _animation.value;

              if (t <= 0.5) {
                // Phase 1: Top flap is rotating down from 0 to -90 deg
                final angle = -t * math.pi;
                final topShadow = (t * 2 * 0.6).clamp(0.0, 0.8);
                final bottomShadow = (t * 2 * 0.4).clamp(0.0, 0.6);

                return Stack(
                  children: [
                    // Underneath: Incoming digit top half
                    ClipRect(
                      clipper: const TopCardClipper(),
                      child: _buildHalfCard(
                        digit: _currentDigit,
                        width: width,
                        height: height,
                        isTop: true,
                        shadowOpacity: 0.0,
                      ),
                    ),
                    // Underneath: Old digit bottom half
                    ClipRect(
                      clipper: const BottomCardClipper(),
                      child: _buildHalfCard(
                        digit: _oldDigit,
                        width: width,
                        height: height,
                        isTop: false,
                        shadowOpacity: bottomShadow,
                      ),
                    ),
                    // Top Flap rotating down around center hinge
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateX(angle),
                      alignment: Alignment.center,
                      child: ClipRect(
                        clipper: const TopCardClipper(),
                        child: _buildHalfCard(
                          digit: _oldDigit,
                          width: width,
                          height: height,
                          isTop: true,
                          shadowOpacity: topShadow,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Phase 2: Bottom flap is landing from 90 deg down to 0 deg
                final angle = (math.pi - t * math.pi);
                final bottomShadow = ((1.0 - t) * 2 * 0.6).clamp(0.0, 0.8);

                return Stack(
                  children: [
                    // Fully visible new top half
                    ClipRect(
                      clipper: const TopCardClipper(),
                      child: _buildHalfCard(
                        digit: _currentDigit,
                        width: width,
                        height: height,
                        isTop: true,
                        shadowOpacity: 0.0,
                      ),
                    ),
                    // Underneath old bottom half
                    ClipRect(
                      clipper: const BottomCardClipper(),
                      child: _buildHalfCard(
                        digit: _oldDigit,
                        width: width,
                        height: height,
                        isTop: false,
                        shadowOpacity: 0.0,
                      ),
                    ),
                    // Bottom Flap landing onto bottom half
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateX(angle),
                      alignment: Alignment.center,
                      child: ClipRect(
                        clipper: const BottomCardClipper(),
                        child: _buildHalfCard(
                          digit: _currentDigit,
                          width: width,
                          height: height,
                          isTop: false,
                          shadowOpacity: bottomShadow,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          // Horizontal Split Hinge Line
          Positioned(
            top: height / 2 - 0.75,
            left: 0,
            right: 0,
            height: 1.5,
            child: Container(
              color: const Color(0xFF070B13),
            ),
          ),

          // Left Mechanical Axle Pin Notch
          Positioned(
            left: 0,
            top: height / 2 - 4,
            width: 4,
            height: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF080C14),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(3),
                ),
              ),
            ),
          ),

          // Right Mechanical Axle Pin Notch
          Positioned(
            right: 0,
            top: height / 2 - 4,
            width: 4,
            height: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF080C14),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Colon Separator with glowing pulsating dots.
class FlipColonSeparator extends StatefulWidget {
  final Color color;
  final bool isBlinking;
  final double height;

  const FlipColonSeparator({
    Key? key,
    required this.color,
    this.isBlinking = false,
    this.height = 84.0,
  }) : super(key: key);

  @override
  State<FlipColonSeparator> createState() => _FlipColonSeparatorState();
}

class _FlipColonSeparatorState extends State<FlipColonSeparator>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isBlinking) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant FlipColonSeparator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking != oldWidget.isBlinking) {
      if (widget.isBlinking) {
        _blinkController.repeat(reverse: true);
      } else {
        _blinkController.stop();
        _blinkController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _blinkController,
        builder: (context, child) {
          final opacity = widget.isBlinking
              ? (0.3 + 0.7 * _blinkController.value).clamp(0.0, 1.0)
              : 1.0;
          return Opacity(
            opacity: opacity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(),
                const SizedBox(height: 12),
                _buildDot(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Ultra-Realistic 3D Flip Clock Pomodoro Widget for Flutter.
class FlipClockWidget extends StatelessWidget {
  final int timeLeft;
  final int totalTime;
  final Color accentColor;
  final String modeLabel;
  final bool isActive;
  final double cardWidth;
  final double cardHeight;

  const FlipClockWidget({
    Key? key,
    required this.timeLeft,
    this.totalTime = 1500,
    required this.accentColor,
    required this.modeLabel,
    this.isActive = false,
    this.cardWidth = 52.0,
    this.cardHeight = 84.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clampedTime = math.max(0, timeLeft);
    final minutes = clampedTime ~/ 60;
    final seconds = clampedTime % 60;

    final m1 = (minutes ~/ 10) % 10;
    final m2 = minutes % 10;
    final s1 = (seconds ~/ 10) % 10;
    final s2 = seconds % 10;

    final progress = totalTime > 0
        ? ((totalTime - clampedTime) / totalTime).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust responsive dimensions if constraints are tight
        final maxWidth = constraints.maxWidth;
        final responsiveWidth = maxWidth < 340 ? 44.0 : cardWidth;
        final responsiveHeight = maxWidth < 340 ? 72.0 : cardHeight;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Session Status Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withOpacity(0.25),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: accentColor.withOpacity(0.7),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$modeLabel • ${isActive ? 'جارية الآن' : 'متوقف مؤقتاً'}',
                    style: AppTextStyles.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Flip Clock Row [Minutes Pair] : [Seconds Pair]
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minutes Pair
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlipCardDigit(
                        digit: m1,
                        width: responsiveWidth,
                        height: responsiveHeight,
                      ),
                      const SizedBox(width: 4),
                      FlipCardDigit(
                        digit: m2,
                        width: responsiveWidth,
                        height: responsiveHeight,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Colon Separator
                  FlipColonSeparator(
                    color: accentColor,
                    isBlinking: isActive,
                    height: responsiveHeight,
                  ),
                  const SizedBox(width: 8),

                  // Seconds Pair
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlipCardDigit(
                        digit: s1,
                        width: responsiveWidth,
                        height: responsiveHeight,
                      ),
                      const SizedBox(width: 4),
                      FlipCardDigit(
                        digit: s2,
                        width: responsiveWidth,
                        height: responsiveHeight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress Bar Track
            Container(
              width: math.min(maxWidth, 280.0),
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0x2094A3B8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
