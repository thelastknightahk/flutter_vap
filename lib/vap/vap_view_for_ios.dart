import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'vap_controller.dart';
 

class VapViewForIos extends StatelessWidget {
  final VapController? controller; // Add controller parameter

  const VapViewForIos({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'controllerId': controller?.hashCode, // Pass controller ID to native side
    };
    return UiKitView(
      viewType: "flutter_vap",
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
