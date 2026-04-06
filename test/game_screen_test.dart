import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bounce_dash_app/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
  });

  group('MenuScreen', () {
    testWidgets('displays app title and icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.text('Bounce Dash'), findsOneWidget);
      expect(find.text('Jump over obstacles!'), findsOneWidget);
      expect(find.byIcon(Icons.sports_volleyball), findsAtLeastNWidgets(1));
    });

    testWidgets('displays high score', (tester) async {
      SharedPreferences.setMockInitialValues({'highScore': 125});
      await SettingsService.instance.init();

      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.textContaining('Best: 125'), findsOneWidget);
    });

    testWidgets('has start button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.text('START'), findsOneWidget);
    });

    testWidgets('has settings and achievements buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsAtLeastNWidgets(1));
    });
  });

  group('SettingsScreen', () {
    testWidgets('displays sound toggle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();

      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('displays vibration toggle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();

      expect(find.text('Vibration'), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });

    testWidgets('toggles sound setting', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();

      expect(SettingsService.instance.soundEnabled, true);

      final soundSwitch = find.byType(SwitchListTile).first;
      await tester.tap(soundSwitch);
      await tester.pump();

      expect(SettingsService.instance.soundEnabled, false);
    });

    testWidgets('displays app version info', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();

      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.text('© 2026 Heldig Lab'), findsOneWidget);
      expect(find.text('heldig.lab@pm.me'), findsOneWidget);
    });
  });

  group('AchievementsScreen', () {
    testWidgets('displays all achievements', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
      await tester.pump();

      expect(find.text('Jump Start'), findsOneWidget);
      expect(find.text('Bounce Master'), findsOneWidget);
      expect(find.text('Dash Legend'), findsOneWidget);
      expect(find.text('Unstoppable'), findsOneWidget);
    });

    testWidgets('shows locked achievements', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });

    testWidgets('shows unlocked achievements', (tester) async {
      SharedPreferences.setMockInitialValues({'achievements': ['first_10']});
      await SettingsService.instance.init();

      await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.emoji_events), findsAtLeastNWidgets(1));
    });
  });
}
