import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bounce_dash_app/main.dart';

void main() {
  group('SettingsService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with default values', () async {
      await SettingsService.instance.init();

      expect(SettingsService.instance.soundEnabled, true);
      expect(SettingsService.instance.vibrationEnabled, true);
      expect(SettingsService.instance.highScore, 0);
      expect(SettingsService.instance.gamesPlayed, 0);
      expect(SettingsService.instance.hasSeenTutorial, false);
      expect(SettingsService.instance.unlockedAchievements, isEmpty);
    });

    test('loads saved preferences', () async {
      SharedPreferences.setMockInitialValues({
        'sound': false,
        'vibration': false,
        'highScore': 150,
        'gamesPlayed': 7,
        'hasSeenTutorial': true,
        'achievements': ['first_10', 'score_50'],
      });

      await SettingsService.instance.init();

      expect(SettingsService.instance.soundEnabled, false);
      expect(SettingsService.instance.vibrationEnabled, false);
      expect(SettingsService.instance.highScore, 150);
      expect(SettingsService.instance.gamesPlayed, 7);
      expect(SettingsService.instance.hasSeenTutorial, true);
      expect(SettingsService.instance.unlockedAchievements, {'first_10', 'score_50'});
    });

    test('setSoundEnabled updates setting', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.setSoundEnabled(false);

      expect(SettingsService.instance.soundEnabled, false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sound'), false);
    });

    test('setVibrationEnabled updates setting', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.setVibrationEnabled(false);

      expect(SettingsService.instance.vibrationEnabled, false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('vibration'), false);
    });

    test('saveScore updates high score when higher', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.saveScore(100);

      expect(SettingsService.instance.highScore, 100);
      expect(SettingsService.instance.gamesPlayed, 1);

      await SettingsService.instance.saveScore(150);
      expect(SettingsService.instance.highScore, 150);
      expect(SettingsService.instance.gamesPlayed, 2);
    });

    test('saveScore does not update high score when lower', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.saveScore(150);
      await SettingsService.instance.saveScore(100);

      expect(SettingsService.instance.highScore, 150);
      expect(SettingsService.instance.gamesPlayed, 2);
    });

    test('markTutorialSeen updates flag', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.markTutorialSeen();

      expect(SettingsService.instance.hasSeenTutorial, true);
    });

    test('unlockAchievement adds new achievement', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.unlockAchievement('first_10');

      expect(SettingsService.instance.unlockedAchievements, {'first_10'});
    });

    test('unlockAchievement does not duplicate achievements', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.unlockAchievement('first_10');
      await SettingsService.instance.unlockAchievement('first_10');

      expect(SettingsService.instance.unlockedAchievements, {'first_10'});
    });
  });
}
