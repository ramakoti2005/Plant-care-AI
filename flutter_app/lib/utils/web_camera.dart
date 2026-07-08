import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'web_camera_stub.dart'
    if (dart.library.html) 'web_camera_web.dart';

Future<Uint8List?> getWebCameraImage(BuildContext context) async {
  return await captureWebCamera(context);
}
