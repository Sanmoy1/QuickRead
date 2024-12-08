import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsProvider with ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  TtsState _ttsState = TtsState.stopped;
  String _currentText = '';
  bool _isInitialized = false;

  TtsState get ttsState => _ttsState;
  bool get isPlaying => _ttsState == TtsState.playing;
  bool get isStopped => _ttsState == TtsState.stopped;

  TtsProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(0.0);
    await _flutterTts.setVoice({'name': 'en-us-x-iol-local', 'locale': 'en-US'});

    _flutterTts.setCompletionHandler(() {
      stop();
    });

    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    if (_currentText == text && isPlaying) {
      await pause();
      return;
    }

    if (_currentText == text && _ttsState == TtsState.paused) {
      await resume();
      return;
    }

    _currentText = text;
    _ttsState = TtsState.playing;
    await _flutterTts.speak(text);
    notifyListeners();
  }

  Future<void> pause() async {
    if (_ttsState == TtsState.playing) {
      _ttsState = TtsState.paused;
      await _flutterTts.pause();
      notifyListeners();
    }
  }

  Future<void> resume() async {
    if (_ttsState == TtsState.paused) {
      _ttsState = TtsState.playing;
      await _flutterTts.speak(_currentText);
      notifyListeners();
    }
  }

  Future<void> stop() async {
    _ttsState = TtsState.stopped;
    _currentText = '';
    await _flutterTts.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
