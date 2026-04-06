import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Ground component - static platform at bottom of screen
/// Provides surface for ball to bounce on
class Ground extends BodyComponent {
  final Vector2 position;
  final double width;
  final Color color;

  Ground({
    required this.position,
    required this.width,
    this.color = const Color(0xFF4CAF50),
  }) : super(priority: 10);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(
        width / 2,
        0.5, // Ground thickness
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.5,
      restitution: 0.0,
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
      width: width * 2,
      height: 1.0,
    );

    canvas.drawRect(rect, paint);
  }
}
