import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:safe_device/safe_device.dart';
import 'package:android_intent_plus/android_intent.dart';

class SecurityService {
  Future<bool> isEnvironmentUnsafe() async {
    if (kDebugMode) {
      return false;
    }

    try {
      // Check for Developer Mode/USB Debugging
      bool isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;
      if (isDevelopmentModeEnable) return true;

      // Check for Rooted/Jailbroken device
      bool isJailBroken = await SafeDevice.isJailBroken;
      if (isJailBroken) return true;

      // Check if the app is running on an emulator
      bool isRealDevice = await SafeDevice.isRealDevice;
      if (!isRealDevice) return true;

      // Check for Mock Locations
      bool isMockLocation = await SafeDevice.isMockLocation;
      if (isMockLocation) return true;

      return false;
    } catch (e) {
      debugPrint("Security check failed: $e");
      return false;
    }
  }

  /// Opens the Android Developer Options settings page.
  Future<void> openDeveloperSettings() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.APPLICATION_DEVELOPMENT_SETTINGS',
      );
      await intent.launch();
    }
  }

  void forceQuit() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}
