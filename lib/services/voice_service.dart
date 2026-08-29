// lib/services/voice_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Service to handle voice-to-text conversion
class VoiceService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  /// Check if voice service is available on device
  Future<bool> isAvailable() async {
    try {
      return await _speechToText.initialize(
        onError: (error) {
          // Handle error silently
        },
        onStatus: (status) {
          // Handle status silently
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Request microphone permission from user
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Start listening for voice input
  Future<String?> startListening({
    String locale = 'en_US',
  }) async {
    // Check permission first
    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      return null;
    }

    // Check if speech recognition is available
    if (!await isAvailable()) {
      return null;
    }

    _recognizedText = '';
    _isListening = true;

    try {
      await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
        },
        localeId: locale,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
      );

      return _recognizedText;
    } catch (e) {
      _isListening = false;
      return null;
    }
  }

  /// Stop listening and return final recognized text
  Future<String> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    return _recognizedText;
  }

  /// Cancel voice input and clear text
  void cancel() {
    _speechToText.cancel();
    _isListening = false;
    _recognizedText = '';
  }

  /// Get current recognized text while listening
  String get currentText => _recognizedText;

  /// Cleanup resources
  void dispose() {
    _speechToText.cancel();
  }
}