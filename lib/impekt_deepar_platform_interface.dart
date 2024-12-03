import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'impekt_deepar_method_channel.dart';

abstract class ImpektDeeparPlatform extends PlatformInterface {
  /// Constructs a ImpektDeeparPlatform.
  ImpektDeeparPlatform() : super(token: _token);

  static final Object _token = Object();

  static ImpektDeeparPlatform _instance = MethodChannelImpektDeepar();

  /// The default instance of [ImpektDeeparPlatform] to use.
  ///
  /// Defaults to [MethodChannelImpektDeepar].
  static ImpektDeeparPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ImpektDeeparPlatform] when
  /// they register themselves.
  static set instance(ImpektDeeparPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
