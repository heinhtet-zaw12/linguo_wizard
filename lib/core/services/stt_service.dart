import 'package:speech_to_text/speech_to_text.dart';
import '../config/app_config.dart';

/// Wraps the speech_to_text package in a clean async interface.
class SttService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  /// Initializes the speech recognition engine.
  /// Returns true if initialization succeeded.
  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  /// Starts listening for speech input.
  ///
  /// [onResult] is called with each partial or final result.
  /// [onSoundLevel] optionally receives the current sound level (0-1).
  /// [localeId] optionally overrides the recognition language.
  Future<void> startListening({
    required SpeechResultListener onResult,
    SpeechSoundLevelChange? onSoundLevel,
    String? localeId,
  }) async {
    await _speech.listen(
      onResult: onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        listenFor: AppConfig.sttListenTimeout,
        pauseFor: AppConfig.sttPauseTimeout,
        localeId: localeId,
      ),
      onSoundLevelChange: onSoundLevel,
    );
  }

  /// Stops the current listening session.
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Whether the engine is currently listening for speech.
  bool get isListening => _speech.isListening;
}
