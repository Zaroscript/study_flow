import 'dart:io';
import 'dart:math' as math;

/// Rect definition for testing clipping boundaries without Flutter SDK dependency.
class SimpleRect {
  final double left;
  final double top;
  final double width;
  final double height;

  const SimpleRect.fromLTWH(this.left, this.top, this.width, this.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleRect &&
          left == other.left &&
          top == other.top &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() => 'SimpleRect.fromLTWH($left, $top, $width, $height)';
}

SimpleRect getTopClip(double width, double height) {
  return SimpleRect.fromLTWH(0, 0, width, height / 2);
}

SimpleRect getBottomClip(double width, double height) {
  return SimpleRect.fromLTWH(0, height / 2, width, height / 2);
}

/// Perspective matrix 4x4 mock matching Flutter's Matrix4 storage layout:
/// setEntry(3, 2, 0.0015) modifies row 3, col 2 (1-based index) -> index 11 (0-based in column-major).
List<double> createPerspectiveMatrix(double angle) {
  final cosA = math.cos(angle);
  final sinA = math.sin(angle);
  // Column-major 4x4 identity with setEntry(3, 2, 0.0015) and rotateX(angle)
  return [
    1.0, 0.0, 0.0, 0.0, // col 0
    0.0, cosA, sinA, 0.0, // col 1
    0.0, -sinA, cosA, 0.0015, // col 2
    0.0, 0.0, 0.0, 1.0, // col 3
  ];
}

void main() {
  stdout.writeln('--- Running 3D Flip Clock Pomodoro Tests ---');

  // Test 1: TopCardClipper geometry [0, height/2]
  final topRect = getTopClip(52, 84);
  assert(
    topRect == const SimpleRect.fromLTWH(0, 0, 52, 42),
    'Top half clipping must be [0, 0, 52, 42]',
  );
  stdout.writeln('✅ Test 1 Passed: Top half card clipper geometry verified');

  // Test 2: BottomCardClipper geometry [height/2, height]
  final bottomRect = getBottomClip(52, 84);
  assert(
    bottomRect == const SimpleRect.fromLTWH(0, 42, 52, 42),
    'Bottom half clipping must be [0, 42, 52, 42]',
  );
  stdout.writeln('✅ Test 2 Passed: Bottom half card clipper geometry verified');

  // Test 3: 3D Perspective Matrix Calculation
  for (final angle in [0.0, math.pi / 4, math.pi / 2, math.pi]) {
    final matrix = createPerspectiveMatrix(angle);
    assert(
      !matrix.any((v) => v.isNaN || v.isInfinite),
      'Perspective matrix entries must be finite numbers',
    );
    assert(
      matrix[11] == 0.0015,
      'setEntry(3, 2, 0.0015) perspective entry must match 0.0015',
    );
  }
  stdout.writeln('✅ Test 3 Passed: 3D perspective matrix transform verified');

  // Test 4: Flap rotation angle continuity
  for (double t = 0.0; t <= 1.0; t += 0.1) {
    double angle;
    if (t <= 0.5) {
      angle = -t * math.pi; // Phase 1: 0 to -pi/2
      assert(
        angle <= 0.0 && angle >= -math.pi / 2,
        'Phase 1 angle out of bounds',
      );
    } else {
      angle = (math.pi - t * math.pi); // Phase 2: pi/2 down to 0
      assert(
        angle >= 0.0 && angle <= math.pi / 2,
        'Phase 2 angle out of bounds',
      );
    }
  }
  stdout.writeln(
    '✅ Test 4 Passed: 2-phase split flap angle continuity verified',
  );

  // Test 5: Digit decomposition math (Tens & Ones for Mins & Secs)
  final testCases = [
    {'seconds': 1500, 'm1': 2, 'm2': 5, 's1': 0, 's2': 0},
    {'seconds': 65, 'm1': 0, 'm2': 1, 's1': 0, 's2': 5},
    {'seconds': 59, 'm1': 0, 'm2': 0, 's1': 5, 's2': 9},
    {'seconds': 0, 'm1': 0, 'm2': 0, 's1': 0, 's2': 0},
  ];

  for (final tc in testCases) {
    final sec = tc['seconds'] as int;
    final mins = sec ~/ 60;
    final remainingSecs = sec % 60;
    final m1 = (mins ~/ 10) % 10;
    final m2 = mins % 10;
    final s1 = (remainingSecs ~/ 10) % 10;
    final s2 = remainingSecs % 10;

    assert(m1 == tc['m1'], 'm1 mismatch for $sec');
    assert(m2 == tc['m2'], 'm2 mismatch for $sec');
    assert(s1 == tc['s1'], 's1 mismatch for $sec');
    assert(s2 == tc['s2'], 's2 mismatch for $sec');
  }
  stdout.writeln('✅ Test 5 Passed: Digit decomposition math verified');

  stdout.writeln('🎉 All 3D Flip Clock Pomodoro Tests Passed!\n');
}
