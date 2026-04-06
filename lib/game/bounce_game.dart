import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'world/bounce_world.dart';

/// Bounce Dash Flame game with Forge2D physics
/// Handles input, camera, and delegates physics to BounceWorld
class BounceGame extends FlameGame with TapCallbacks {
  final VoidCallback onGameOver;
  final Function(int) onScoreUpdate;

  late BounceWorld gameWorld;
  bool isHolding = false;

  BounceGame({
    required this.onGameOver,
    required this.onScoreUpdate,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set fixed camera viewport for consistent physics
    camera.viewfinder.visibleGameSize = Vector2(12, 20);
    camera.viewfinder.position = Vector2(0, 10);

    // Create and add the Forge2D world
    gameWorld = BounceWorld(
      onGameOver: onGameOver,
      onScoreUpdate: onScoreUpdate,
    );

    await add(gameWorld);
  }

  @override
  void onTapDown(TapDownEvent event) {
    isHolding = true;
    gameWorld.handleJump(true);
  }

  @override
  void onTapUp(TapUpEvent event) {
    isHolding = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isHolding = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Continuous jump while holding
    if (isHolding) {
      gameWorld.handleJump(true);
    }
  }

  void resetGame() {
    gameWorld.resetGame();
    isHolding = false;
  }

  @override
  Color backgroundColor() => const Color(0xFFE3F2FD);
}
