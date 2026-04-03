import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(const BounceDashApp());

class BounceDashApp extends StatelessWidget {
  const BounceDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bounce Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.orange.shade700,
          secondary: Colors.deepOrange,
        ),
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_volleyball, size: 120, color: Colors.orange.shade700),
            const SizedBox(height: 24),
            const Text(
              'Bounce Dash',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hold to jump!',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('START', style: TextStyle(fontSize: 28)),
            ),
          ],
        ),
      ),
    );
  }
}

class Obstacle {
  double x;
  final double height;
  final Color color;

  Obstacle({required this.x, required this.height, required this.color});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();

  double ballY = 0.5; // 0.0 (top) to 1.0 (bottom)
  double ballVY = 0.0;
  final double gravity = 0.015;
  final double jumpPower = -0.025;

  List<Obstacle> obstacles = [];
  double obstacleSpeed = 0.01;
  int score = 0;
  bool gameOver = false;
  bool isHolding = false;

  final double groundY = 0.8;
  final double ballSize = 40;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..repeat();

    _controller.addListener(_updateGame);

    // Spawn initial obstacles
    _spawnObstacle();
  }

  void _spawnObstacle() {
    setState(() {
      obstacles.add(Obstacle(
        x: 1.2,
        height: 50 + random.nextDouble() * 100,
        color: Colors.primaries[random.nextInt(Colors.primaries.length)],
      ));
    });
  }

  void _updateGame() {
    if (gameOver) return;

    setState(() {
      // Apply gravity
      ballVY += gravity;

      // Hold to jump
      if (isHolding && ballY >= groundY - 0.05) {
        ballVY = jumpPower;
      }

      // Update ball position
      ballY += ballVY;

      // Ground collision
      if (ballY >= groundY) {
        ballY = groundY;
        ballVY = 0;
      }

      // Top collision
      if (ballY <= 0) {
        ballY = 0;
        ballVY = 0;
      }

      // Move obstacles
      for (var obstacle in obstacles) {
        obstacle.x -= obstacleSpeed;
      }

      // Remove off-screen obstacles and add score
      obstacles.removeWhere((obstacle) {
        if (obstacle.x < -0.2) {
          score += 10;
          obstacleSpeed += 0.0002; // Gradually increase difficulty
          return true;
        }
        return false;
      });

      // Spawn new obstacles
      if (obstacles.isEmpty || obstacles.last.x < 0.7) {
        _spawnObstacle();
      }

      // Collision detection
      _checkCollision();
    });
  }

  void _checkCollision() {
    final screenHeight = MediaQuery.of(context).size.height;
    final ballPixelY = ballY * screenHeight;

    for (var obstacle in obstacles) {
      final screenWidth = MediaQuery.of(context).size.width;
      final obstaclePixelX = obstacle.x * screenWidth;
      final obstacleLeft = obstaclePixelX;
      final obstacleRight = obstaclePixelX + 50;

      final ballLeft = screenWidth * 0.2 - ballSize / 2;
      final ballRight = screenWidth * 0.2 + ballSize / 2;
      final ballBottom = ballPixelY + ballSize / 2;

      // Check horizontal overlap
      if (ballRight > obstacleLeft && ballLeft < obstacleRight) {
        // Check vertical collision
        final obstacleTop = screenHeight * groundY - obstacle.height;
        if (ballBottom > obstacleTop) {
          _endGame();
        }
      }
    }
  }

  void _endGame() {
    setState(() {
      gameOver = true;
    });
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (gameOver) {
      return Scaffold(
        backgroundColor: Colors.lightBlue.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.close, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Game Over!',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $score',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('MENU', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        title: Text('Score: $score', style: const TextStyle(fontSize: 24)),
      ),
      body: GestureDetector(
        onTapDown: (_) => setState(() => isHolding = true),
        onTapUp: (_) => setState(() => isHolding = false),
        onTapCancel: () => setState(() => isHolding = false),
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Ground
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * (1 - groundY),
                  color: Colors.green.shade700,
                ),
              ),

              // Ball
              Positioned(
                left: screenWidth * 0.2 - ballSize / 2,
                top: ballY * screenHeight - ballSize / 2,
                child: Container(
                  width: ballSize,
                  height: ballSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.shade700,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // Obstacles
              ...obstacles.map((obstacle) {
                return Positioned(
                  left: obstacle.x * screenWidth,
                  bottom: screenHeight * (1 - groundY),
                  child: Container(
                    width: 50,
                    height: obstacle.height,
                    decoration: BoxDecoration(
                      color: obstacle.color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                );
              }).toList(),

              // Instructions
              if (score == 0)
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'HOLD TO JUMP',
                        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
