import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Ball physics component for Bounce Dash
/// Uses Forge2D for realistic gravity, bounce, and collision physics
class Ball extends BodyComponent {
  final double radius;
  final Color color;
  final Vector2 initialPosition;
  bool canJump = true;

  Ball({
    required this.initialPosition,
    this.radius = 0.4,
    this.color = const Color(0xFFFF6F00),
  }) : super(
          priority: 100, // Render on top
        );

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.dynamic,
      fixedRotation: false,
    );

    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      friction: 0.3,
      restitution: 0.7, // High bounce for fun gameplay
    );

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset.zero,
      radius * 1.3,
      glowPaint,
    );

    // Draw main ball
    canvas.drawCircle(
      Offset.zero,
      radius,
      paint,
    );

    // Draw highlight for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.3,
      highlightPaint,
    );
  }

  void jump() {
    if (canJump && body.linearVelocity.y.abs() < 0.5) {
      // Apply upward impulse for jump
      body.applyLinearImpulse(Vector2(0, -8.0));
      canJump = false;
    }
  }

  void resetCanJump() {
    canJump = true;
  }

  void resetPosition(Vector2 newPosition) {
    body.setTransform(newPosition, 0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;
    canJump = true;
  }
}
