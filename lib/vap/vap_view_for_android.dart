import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class VapViewForAndroid extends StatelessWidget {
  const VapViewForAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    return AndroidView(
      viewType: "flutter_vap",
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
