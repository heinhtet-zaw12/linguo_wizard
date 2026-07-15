import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps the flutter_tts package for text-to-speech output.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  /// Initializes TTS with settings optimized for language learners.
  Future<void> initialize() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5); // Slower for learners
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  /// Speaks the given [text] aloud.
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  /// Stops any current speech output.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Registers a callback that fires when speech output completes.
  void setCompletionHandler(VoidCallback onComplete) {
    _tts.setCompletionHandler(onComplete);
  }
}
