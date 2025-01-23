import 'dart:async';
import 'package:flutter/services.dart';

class VapController {
  static const MethodChannel _methodChannel = MethodChannel('flutter_vap_controller');
  static const EventChannel _eventChannel = EventChannel('flutter_vap_event_channel');

  void init() {
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onEvent(dynamic event) {
    // Handle the event
    print('Received event: $event');
  }

  void _onError(Object error) {
    // Handle the error
    print('Error receiving event: $error');
  }

  /// return: play error:       {"status": "failure", "errorMsg": ""}
  ///         play complete:    {"status": "complete"}
  static Future<Map<dynamic, dynamic>?> playPath(String path) async {
    return _methodChannel.invokeMethod('playPath', {"path": path});
  }

  static Future<Map<dynamic, dynamic>?> playAsset(String asset) {
    return _methodChannel.invokeMethod('playAsset', {"asset": asset});
  }

  static stop() {
    _methodChannel.invokeMethod('stop');
  }
}
