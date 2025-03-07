import 'dart:async';
import 'package:flutter/services.dart';

class VapController {
  static const MethodChannel _methodChannel = MethodChannel('flutter_vap_controller');
  static const EventChannel _eventChannel = EventChannel('flutter_vap_event_channel');
   Function()? onVideoComplete;
   void init() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      print("Event received: $event"); // Add this log
      _onEvent(event); 
    }, onError: _onError);
  }

  
  void _onEvent(dynamic event) {
    print("Processing event: $event");
    if (event['status'] == 'complete' && onVideoComplete != null) {
      print("Calling onVideoComplete");
      onVideoComplete!();
    }
  }

  void _onError(Object error) {
    // Handle the error
    print('Error receiving event: $error');
  }

  /// Play a video from a file path
  Future<Map<dynamic, dynamic>?> playPath(String path) async {
    return _methodChannel.invokeMethod('playPath', {"path": path});
  }

  /// Play a video from an asset
  Future<Map<dynamic, dynamic>?> playAsset(String asset) async { // Remove static
    return _methodChannel.invokeMethod('playAsset', {"asset": asset});
  }

  /// Stop the current playback
  Future<void> stop() async {
    await _methodChannel.invokeMethod('stop');
   
  }

  /// Dispose the controller
  Future<void> dispose() async {
    await stop(); // Stop playback before disposing
    // Add any additional cleanup logic here
  }
}