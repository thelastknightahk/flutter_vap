import 'dart:io';
import 'package:flutter/widgets.dart';
import 'vap_view_for_android.dart';
import 'vap_view_for_ios.dart';

class VapView extends StatelessWidget {
  const VapView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return VapViewForAndroid();
    } else if (Platform.isIOS) {
      return VapViewForIos();
    }
    return Container();
  }
}
