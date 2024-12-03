import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'impekt_deepar_platform_interface.dart';

/// An implementation of [ImpektDeeparPlatform] that uses method channels.
class MethodChannelImpektDeepar extends ImpektDeeparPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('impekt_deepar');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
