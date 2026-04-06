import 'package:flutter_test/flutter_test.dart';
import 'package:bounce_dash_app/main.dart';

void main() {
  group('Achievement', () {
    test('creates achievement with correct properties', () {
      final achievement = Achievement(
        id: 'test',
        title: 'Test Title',
        description: 'Test Description',
        target: 75,
      );

      expect(achievement.id, 'test');
      expect(achievement.title, 'Test Title');
      expect(achievement.description, 'Test Description');
      expect(achievement.target, 75);
    });

    test('achievements list contains expected achievements', () {
      expect(achievements.length, 4);
      expect(achievements[0].id, 'first_10');
      expect(achievements[1].id, 'score_50');
      expect(achievements[2].id, 'score_100');
      expect(achievements[3].id, 'score_200');
    });

    test('achievement targets are in ascending order', () {
      for (int i = 0; i < achievements.length - 1; i++) {
        expect(
          achievements[i].target < achievements[i + 1].target,
          true,
          reason: 'Achievement targets should be in ascending order',
        );
      }
    });

    test('achievement ids are unique', () {
      final ids = achievements.map((a) => a.id).toSet();
      expect(ids.length, achievements.length);
    });

    test('all achievements have valid targets', () {
      for (var achievement in achievements) {
        expect(achievement.target, greaterThan(0));
      }
    });
  });
}
