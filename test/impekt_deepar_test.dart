import 'package:flutter_test/flutter_test.dart';
import 'package:impekt_deepar/impekt_deepar.dart';
import 'package:impekt_deepar/impekt_deepar_platform_interface.dart';
import 'package:impekt_deepar/impekt_deepar_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImpektDeeparPlatform
    with MockPlatformInterfaceMixin
    implements ImpektDeeparPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ImpektDeeparPlatform initialPlatform = ImpektDeeparPlatform.instance;

  test('$MethodChannelImpektDeepar is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelImpektDeepar>());
  });

  test('getPlatformVersion', () async {
    // ImpektDeepar impektDeeparPlugin = ImpektDeepar();
    MockImpektDeeparPlatform fakePlatform = MockImpektDeeparPlatform();
    ImpektDeeparPlatform.instance = fakePlatform;

    //expect(await impektDeeparPlugin.getPlatformVersion(), '42');
  });
}
