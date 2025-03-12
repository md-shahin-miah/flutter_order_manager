import 'package:flutter/services.dart';

class SoundService {
  static const platform = MethodChannel('com.example.flutter_order_manager/sound');
  bool _isPlaying = false;

  Future<void> playOrderCreatedSound() async {
    try {
      _isPlaying = true;
      await platform.invokeMethod('playOrderCreatedSound');
    } on PlatformException catch (e) {
      print("Failed to play sound: ${e.message}");
      _isPlaying = false;
    }
  }
  
  Future<void> stopSound() async {
    if (_isPlaying) {
      try {
        await platform.invokeMethod('stopSound');
        _isPlaying = false;
      } on PlatformException catch (e) {
        print("Failed to stop sound: ${e.message}");
      }
    }
  }
  
  bool get isPlaying => _isPlaying;
}

