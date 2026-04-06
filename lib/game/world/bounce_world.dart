import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../components/ball.dart';
import '../components/obstacle.dart';
import '../components/ground.dart';

/// Bounce Dash Forge2D World
/// Manages physics simulation, spawning obstacles, scoring, and collision detection
class BounceWorld extends Forge2DWorld {
  final VoidCallback onGameOver;
  final Function(int) onScoreUpdate;

  late Ball ball;
  late Ground ground;
  final List<Obstacle> obstacles = [];
  final Random random = Random();

  int score = 0;
  bool gameActive = true;
  double obstacleSpeed = 2.0; // Units per second
  double timeSinceLastObstacle = 0;
  final double obstacleSpawnInterval = 2.0; // Seconds between obstacles

  // Camera/world bounds (in Forge2D units)
  final double worldWidth = 12.0;
  final double worldHeight = 20.0;
  final double groundY = 16.0;

  BounceWorld({
    required this.onGameOver,
    required this.onScoreUpdate,
  }) : super(gravity: Vector2(0, 9.8)); // Standard gravity

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create ground
    ground = Ground(
      position: Vector2(0, groundY),
      width: worldWidth * 2,
    );
    add(ground);

    // Create ball
    ball = Ball(
      initialPosition: Vector2(-3, 10),
    );
    add(ball);

    // Spawn initial obstacle
    _spawnObstacle();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameActive) return;

    // Update obstacle spawning
    timeSinceLastObstacle += dt;
    if (timeSinceLastObstacle >= obstacleSpawnInterval) {
      _spawnObstacle();
      timeSinceLastObstacle = 0;
    }

    // Move obstacles left
    for (final obstacle in obstacles) {
      obstacle.moveLeft(obstacleSpeed * dt);
    }

    // Check for scoring (ball passed obstacle)
    _checkScoring();

    // Check for collisions
    _checkCollisions();

    // Remove off-screen obstacles
    obstacles.removeWhere((obstacle) {
      if (obstacle.position.x < -worldWidth) {
        remove(obstacle);
        return true;
      }
      return false;
    });

    // Check game over (ball fell below ground)
    if (ball.position.y > groundY + 5) {
      _handleGameOver();
    }

    // Increase difficulty over time
    obstacleSpeed += dt * 0.05;
  }

  void _spawnObstacle() {
    final height = 1.0 + random.nextDouble() * 2.5;
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];

    final obstacle = Obstacle(
      position: Vector2(worldWidth / 2, groundY - height / 2),
      size: Vector2(0.5, height),
      color: colors[random.nextInt(colors.length)],
    );

    obstacles.add(obstacle);
    add(obstacle);
  }

  void _checkScoring() {
    for (final obstacle in obstacles) {
      if (!obstacle.scored && obstacle.position.x < ball.position.x) {
        obstacle.scored = true;
        _addScore(10);
      }
    }
  }

  void _addScore(int points) {
    score += points;
    onScoreUpdate(score);
  }

  void _handleGameOver() {
    if (!gameActive) return;
    gameActive = false;
    onGameOver();
  }

  void _checkCollisions() {
    // Check ball collision with obstacles
    for (final obstacle in obstacles) {
      final dx = ball.position.x - obstacle.position.x;
      final dy = ball.position.y - obstacle.position.y;

      // Simple AABB collision check
      if (dx.abs() < ball.radius + obstacle.size.x / 2 &&
          dy.abs() < ball.radius + obstacle.size.y / 2) {
        _handleGameOver();
        return;
      }
    }

    // Check ball on ground - allow jump again
    if (ball.position.y >= groundY - 1.0 && ball.body.linearVelocity.y >= 0) {
      ball.resetCanJump();
    }
  }

  void handleJump(bool isHolding) {
    if (!gameActive) return;
    if (isHolding) {
      ball.jump();
    }
  }

  void resetGame() {
    ball.resetPosition(Vector2(-3, 10));

    // Remove all obstacles
    for (final obstacle in obstacles) {
      remove(obstacle);
    }
    obstacles.clear();

    score = 0;
    obstacleSpeed = 2.0;
    timeSinceLastObstacle = 0;
    gameActive = true;
    onScoreUpdate(0);

    _spawnObstacle();
  }
}
