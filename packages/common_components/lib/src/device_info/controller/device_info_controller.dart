import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:android_id/android_id.dart';

class DeviceInfoController {
  static Future<String?> getDeviceUUID() async {
    try {
      if (Platform.isAndroid) {
        final id = await AndroidId().getId();
        return id;
      } else if (Platform.isIOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        return iosInfo.identifierForVendor;
      }
    } catch (error) {
      debugPrint('Error while fetching device UUID: $error');
      rethrow;
    }
  }
}
