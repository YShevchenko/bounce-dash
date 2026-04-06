import 'package:audioplayers/audioplayers.dart';

// ============================================================================
// AUDIO MANAGER - Background music and sound effects
// ============================================================================
class AudioManager {
  static final AudioManager instance = AudioManager._();
  AudioManager._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _isMusicPlaying = false;

  // ============================================================================
  // CONFIGURATION
  // ============================================================================

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled && _isMusicPlaying) {
      stopMusic();
    } else if (enabled && !_isMusicPlaying) {
      // Could auto-resume music here if desired
    }
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  bool get isMusicEnabled => _musicEnabled;
  bool get isSfxEnabled => _sfxEnabled;

  // ============================================================================
  // BACKGROUND MUSIC
  // ============================================================================

  /// Play background music (looping)
  ///
  /// To use: Place audio file in assets/audio/music.mp3
  /// Then add to pubspec.yaml:
  ///   flutter:
  ///     assets:
  ///       - assets/audio/
  Future<void> playMusic({String asset = 'assets/audio/music.mp3'}) async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.5);
      await _musicPlayer.play(AssetSource(asset.replaceFirst('assets/', '')));
      _isMusicPlaying = true;
    } catch (e) {
      // Music file not found or error - silently fail
      // Add actual music file to assets/audio/music.mp3 when ready
      print('Music file not found: $asset');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_musicEnabled && _isMusicPlaying) {
      await _musicPlayer.resume();
    }
  }

  Future<void> setMusicVolume(double volume) async {
    await _musicPlayer.setVolume(volume);
  }

  // ============================================================================
  // SOUND EFFECTS
  // ============================================================================

  /// Play a sound effect
  ///
  /// To use: Place audio files in assets/audio/sfx/
  /// Then add to pubspec.yaml:
  ///   flutter:
  ///     assets:
  ///       - assets/audio/sfx/
  Future<void> playSfx(SoundEffect sfx) async {
    if (!_sfxEnabled) return;

    try {
      await _sfxPlayer.play(AssetSource(sfx.asset.replaceFirst('assets/', '')));
    } catch (e) {
      // Sound file not found or error - silently fail
      // Add actual sound files when ready
      print('Sound file not found: ${sfx.asset}');
    }
  }

  Future<void> setSfxVolume(double volume) async {
    await _sfxPlayer.setVolume(volume);
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

// ============================================================================
// SOUND EFFECTS ENUM
// ============================================================================
enum SoundEffect {
  tap('assets/audio/sfx/tap.mp3'),
  success('assets/audio/sfx/success.mp3'),
  fail('assets/audio/sfx/fail.mp3'),
  achievement('assets/audio/sfx/achievement.mp3'),
  button('assets/audio/sfx/button.mp3'),
  explosion('assets/audio/sfx/explosion.mp3'),
  bounce('assets/audio/sfx/bounce.mp3'),
  hit('assets/audio/sfx/hit.mp3');

  final String asset;
  const SoundEffect(this.asset);
}

// ============================================================================
// USAGE EXAMPLE
// ============================================================================
/*

// In main.dart initialization:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.init();

  // Start background music
  AudioManager.instance.playMusic();

  runApp(const MyApp());
}

// In gameplay:
void onTap() {
  AudioManager.instance.playSfx(SoundEffect.tap);
  // game logic...
}

void onSuccess() {
  AudioManager.instance.playSfx(SoundEffect.success);
}

void onAchievement() {
  AudioManager.instance.playSfx(SoundEffect.achievement);
}

// In settings:
void toggleMusic(bool value) {
  AudioManager.instance.setMusicEnabled(value);
  SettingsService.instance.setSoundEnabled(value);
}

// When pausing game:
void onPause() {
  AudioManager.instance.pauseMusic();
}

void onResume() {
  AudioManager.instance.resumeMusic();
}

// ============================================================================
// REQUIRED AUDIO FILES (Place in assets/audio/)
// ============================================================================
//
// Background Music:
//   - assets/audio/music.mp3 (looping background music, 1-2 minutes)
//
// Sound Effects (in assets/audio/sfx/):
//   - tap.mp3 (short click sound, ~0.1s)
//   - success.mp3 (level complete sound, ~0.5s)
//   - fail.mp3 (game over sound, ~0.5s)
//   - achievement.mp3 (achievement unlock sound, ~1s)
//   - button.mp3 (menu button click, ~0.1s)
//   - explosion.mp3 (explosion/hit sound, ~0.3s)
//   - bounce.mp3 (bounce/jump sound, ~0.2s)
//   - hit.mp3 (collision/hit sound, ~0.1s)
//
// Recommended sources for free game audio:
//   - freesound.org
//   - opengameart.org
//   - incompetech.com (music)
//   - zapsplat.com
//
// OR generate with AI:
//   - elevenlabs.io/sound-effects
//   - sounds.studio
//
*/
