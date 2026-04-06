import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flame/game.dart';
import 'services/iap_service.dart';
import 'game/bounce_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SettingsService.instance.init();

  // Initialize IAP service
  try { await IAPService.instance.initialize(); } catch (_) {}

  runApp(const BounceDashApp());
}

// ============================================================================
// SETTINGS SERVICE
// ============================================================================
class SettingsService {
  static final SettingsService instance = SettingsService._();
  SettingsService._();

  late SharedPreferences _prefs;

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  int highScore = 0;
  int gamesPlayed = 0;
  bool hasSeenTutorial = false;
  Set<String> unlockedAchievements = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    soundEnabled = _prefs.getBool('sound') ?? true;
    vibrationEnabled = _prefs.getBool('vibration') ?? true;
    highScore = _prefs.getInt('highScore') ?? 0;
    gamesPlayed = _prefs.getInt('gamesPlayed') ?? 0;
    hasSeenTutorial = _prefs.getBool('hasSeenTutorial') ?? false;
    unlockedAchievements = (_prefs.getStringList('achievements') ?? []).toSet();
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    await _prefs.setBool('sound', value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    vibrationEnabled = value;
    await _prefs.setBool('vibration', value);
  }

  Future<void> saveScore(int score) async {
    gamesPlayed++;
    await _prefs.setInt('gamesPlayed', gamesPlayed);

    if (score > highScore) {
      highScore = score;
      await _prefs.setInt('highScore', score);
    }
  }

  Future<void> markTutorialSeen() async {
    hasSeenTutorial = true;
    await _prefs.setBool('hasSeenTutorial', true);
  }

  Future<void> unlockAchievement(String id) async {
    if (!unlockedAchievements.contains(id)) {
      unlockedAchievements.add(id);
      await _prefs.setStringList('achievements', unlockedAchievements.toList());
    }
  }
}

// ============================================================================
// ACHIEVEMENTS
// ============================================================================
class Achievement {
  final String id;
  final String title;
  final String description;
  final int target;

  Achievement({required this.id, required this.title, required this.description, required this.target});
}

final List<Achievement> achievements = [
  Achievement(id: 'first_10', title: 'Jump Start', description: 'Score 10 points', target: 10),
  Achievement(id: 'score_50', title: 'Bounce Master', description: 'Score 50 points', target: 50),
  Achievement(id: 'score_100', title: 'Dash Legend', description: 'Score 100 points', target: 100),
  Achievement(id: 'score_200', title: 'Unstoppable', description: 'Score 200 points', target: 200),
];

// ============================================================================
// MAIN APP
// ============================================================================
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
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.orange.shade300,
          secondary: Colors.deepOrange.shade200,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MenuScreen(),
    );
  }
}

// ============================================================================
// MENU SCREEN
// ============================================================================
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    if (!SettingsService.instance.hasSeenTutorial) {
      Future.delayed(const Duration(milliseconds: 500), _showTutorial);
    }

    _checkRatePrompt();
  }

  void _checkRatePrompt() async {
    if (SettingsService.instance.gamesPlayed >= 3 && SettingsService.instance.gamesPlayed % 5 == 0) {
      Future.delayed(const Duration(seconds: 1), () async {
        final inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        }
      });
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sports_volleyball, color: Colors.orange),
            SizedBox(width: 8),
            Text('How to Play'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏐 Tap and hold to jump!', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('🚧 Jump over obstacles', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('🏆 Each obstacle = 10 points', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('⚡ Speed increases over time!', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              SettingsService.instance.markTutorialSeen();
              Navigator.pop(context);
            },
            child: const Text('GOT IT!', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -20 * _bounceController.value),
                    child: Icon(Icons.sports_volleyball, size: 120, color: Colors.orange.shade700),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Bounce Dash', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Hold to jump!', style: TextStyle(fontSize: 24, color: Colors.grey)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade700, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Best: ${SettingsService.instance.highScore}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  elevation: 8,
                ),
                child: const Text('START', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_events, size: 32),
                    color: Colors.amber.shade700,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 32),
                    color: Colors.orange.shade700,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GAME SCREEN - Forge2D Integration
// ============================================================================
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BounceGame game;
  int score = 0;
  bool gameOver = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    game = BounceGame(
      onGameOver: _handleGameOver,
      onScoreUpdate: _handleScoreUpdate,
    );
  }

  void _handleGameOver() {
    if (SettingsService.instance.soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    setState(() {
      gameOver = true;
    });
    game.pauseEngine();
    SettingsService.instance.saveScore(score);
    _checkAchievements();
  }

  void _handleScoreUpdate(int newScore) {
    setState(() {
      score = newScore;
    });
    _checkAchievements();
  }

  void _checkAchievements() {
    for (var achievement in achievements) {
      if (score >= achievement.target) {
        if (!SettingsService.instance.unlockedAchievements.contains(achievement.id)) {
          SettingsService.instance.unlockAchievement(achievement.id);
          _showAchievementPopup(achievement);
        }
      }
    }
  }

  void _showAchievementPopup(Achievement achievement) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.emoji_events, color: Colors.amber), SizedBox(width: 8), Text('Achievement Unlocked!')],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(achievement.description),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('AWESOME!'))],
      ),
    );
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        game.pauseEngine();
      } else {
        game.resumeEngine();
      }
    });
  }

  void _playAgain() {
    setState(() {
      score = 0;
      gameOver = false;
      isPaused = false;
    });
    game.resetGame();
    game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    if (gameOver) {
      final isNewHighScore = score == SettingsService.instance.highScore && score > 0;

      return Scaffold(
        backgroundColor: Colors.lightBlue.shade50,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNewHighScore ? Icons.emoji_events : Icons.close,
                  size: 80,
                  color: isNewHighScore ? Colors.amber : Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  isNewHighScore ? 'New High Score!' : 'Game Over!',
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Score: $score', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                if (!isNewHighScore) ...[
                  const SizedBox(height: 8),
                  Text('Best: ${SettingsService.instance.highScore}', style: const TextStyle(fontSize: 24, color: Colors.grey)),
                ],
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Share.share('I scored $score in Bounce Dash! 🏐', subject: 'Check out my Bounce Dash score!'),
                      icon: const Icon(Icons.share),
                      label: const Text('SHARE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _playAgain,
                      icon: const Icon(Icons.refresh),
                      label: const Text('PLAY AGAIN'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('BACK TO MENU', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        title: Text('Score: $score', style: const TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
            iconSize: 28,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Forge2D Game Widget
          GameWidget(game: game),
          // Pause overlay
          if (isPaused)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pause_circle, size: 100, color: Colors.white),
                    const SizedBox(height: 24),
                    const Text('PAUSED', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _togglePause,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('RESUME', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('QUIT', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// SETTINGS & ACHIEVEMENTS SCREENS
// ============================================================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Sound Effects', style: TextStyle(fontSize: 18)),
            subtitle: const Text('Game sounds'),
            value: SettingsService.instance.soundEnabled,
            onChanged: (value) => setState(() => SettingsService.instance.setSoundEnabled(value)),
            secondary: const Icon(Icons.volume_up),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Vibration', style: TextStyle(fontSize: 18)),
            subtitle: const Text('Haptic feedback'),
            value: SettingsService.instance.vibrationEnabled,
            onChanged: (value) => setState(() => SettingsService.instance.setVibrationEnabled(value)),
            secondary: const Icon(Icons.vibration),
          ),
          const Divider(),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How to Play', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('How to Play'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏐 Tap and hold to jump!'),
                    SizedBox(height: 8),
                    Text('🚧 Jump over obstacles'),
                    SizedBox(height: 8),
                    Text('🏆 Each obstacle = 10 points'),
                  ],
                ),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('GOT IT!'))],
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate This App', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              }
            },
          ),
          const Divider(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.sports_volleyball, size: 60, color: Colors.orange.shade700),
                const SizedBox(height: 8),
                const Text('Bounce Dash', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('© 2026 Heldig Lab', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final isUnlocked = SettingsService.instance.unlockedAchievements.contains(achievement.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                isUnlocked ? Icons.emoji_events : Icons.lock_outline,
                size: 40,
                color: isUnlocked ? Colors.amber.shade700 : Colors.grey,
              ),
              title: Text(
                achievement.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black : Colors.grey),
              ),
              subtitle: Text(achievement.description, style: TextStyle(color: isUnlocked ? Colors.black87 : Colors.grey)),
            ),
          );
        },
      ),
    );
  }
}
