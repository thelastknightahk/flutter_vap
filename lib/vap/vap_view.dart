import 'dart:io'; 
import 'package:flutter/material.dart';

import 'vap_controller.dart';
import 'vap_view_for_android.dart';
import 'vap_view_for_ios.dart';

class VapView extends StatelessWidget {
  final VapController? controller; // Add controller parameter

  const VapView({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return VapViewForAndroid(controller: controller); // Pass controller
    } else if (Platform.isIOS) {
      return VapViewForIos(controller: controller); // Pass controller
    }
    return Container();
  }
}
