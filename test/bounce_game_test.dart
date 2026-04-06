import 'package:flutter_test/flutter_test.dart';
import 'package:bounce_dash_app/game/bounce_game.dart';

void main() {
  group('BounceGame', () {
    test('creates game with callbacks', () {
      var gameOverCalled = false;
      var lastScore = 0;

      final game = BounceGame(
        onGameOver: () => gameOverCalled = true,
        onScoreUpdate: (score) => lastScore = score,
      );

      expect(game, isNotNull);
      expect(game.isHolding, false);
    });

    test('backgroundColor returns correct color', () {
      final game = BounceGame(
        onGameOver: () {},
        onScoreUpdate: (_) {},
      );

      expect(game.backgroundColor().value, 0xFFE3F2FD);
    });

    test('isHolding starts as false', () {
      final game = BounceGame(
        onGameOver: () {},
        onScoreUpdate: (_) {},
      );

      expect(game.isHolding, false);
    });
  });
}
