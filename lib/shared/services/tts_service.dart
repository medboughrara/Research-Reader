import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  final SharedPreferences _prefs;
  bool _isPlaying = false;
  String? _currentDocumentId;
  String? _currentText;
  double _progress = 0.0;

  TTSService(this._prefs) {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(1.0);
    await _tts.setVolume(1.0);
    await _loadPreferences();

    _tts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      _progress = endOffset / text.length;
    });

    _tts.setCompletionHandler(() {
      _isPlaying = false;
      _currentDocumentId = null;
      _currentText = null;
      _progress = 0.0;
    });
  }

  Future<void> _loadPreferences() async {
    final voice = _prefs.getString('tts_voice') ?? 'en-US-Neural2-F';
    final rate = _prefs.getDouble('tts_rate') ?? 1.0;
    await setVoice(voice);
    await setSpeechRate(rate);
  }

  Future<List<dynamic>> getAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      return voices;
    } catch (e) {
      return [];
    }
  }

  Future<void> setVoice(String voice) async {
    await _tts.setVoice({"name": voice});
    await _prefs.setString('tts_voice', voice);
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
    await _prefs.setDouble('tts_rate', rate);
  }

  Future<void> speak(String text, String documentId) async {
    if (_isPlaying && documentId == _currentDocumentId) {
      await stop();
      return;
    }

    if (_isPlaying) {
      await stop();
    }

    _currentDocumentId = documentId;
    _currentText = text;
    _isPlaying = true;
    _progress = 0.0;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _isPlaying = false;
    _currentDocumentId = null;
    _currentText = null;
    _progress = 0.0;
    await _tts.stop();
  }

  Future<void> pause() async {
    if (_isPlaying) {
      _isPlaying = false;
      await _tts.pause();
    }
  }

  Future<void> continueReading() async {
    if (!_isPlaying && _currentText != null && _currentDocumentId != null) {
      _isPlaying = true;
      await _tts.speak(_currentText!);
    }
  }

  bool get isPlaying => _isPlaying;
  String? get currentDocumentId => _currentDocumentId;
  double get progress => _progress;
}
