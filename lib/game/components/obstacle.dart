import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Obstacle component - static rectangular barrier
/// Uses Forge2D for collision detection with ball
class Obstacle extends BodyComponent {
  final Vector2 position;
  final Vector2 size;
  final Color color;
  bool scored = false;

  Obstacle({
    required this.position,
    required this.size,
    required this.color,
  }) : super(priority: 50);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static, // Obstacles don't move
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(
        size.x / 2,
        size.y / 2,
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3,
      restitution: 0.0, // No bounce on obstacles
    );

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x * 2,
      height: size.y * 2,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(0.1),
    );

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.1);

    canvas.drawRRect(
      rrect.shift(const Offset(0.05, 0.05)),
      shadowPaint,
    );

    // Draw obstacle
    canvas.drawRRect(rrect, paint);
  }

  void moveLeft(double speed) {
    position.x -= speed;
    body.setTransform(position, 0);
  }
}
