import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'vap_controller.dart';

class VapViewForAndroid extends StatelessWidget {
  final VapController? controller; // Add controller parameter

  const VapViewForAndroid({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'controllerId': controller?.hashCode, // Pass controller ID to native side
    };
    return AndroidView(
      viewType: "flutter_vap",
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
