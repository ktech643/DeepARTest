import 'package:flutter_test/flutter_test.dart';
import 'package:impekt_deepar/impekt_deepar.dart';
import 'package:impekt_deepar/impekt_deepar_platform_interface.dart';
import 'package:impekt_deepar/impekt_deepar_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockimpektDeeparPlatform
    with MockPlatformInterfaceMixin
    implements impektDeeparPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final impektDeeparPlatform initialPlatform = impektDeeparPlatform.instance;

  test('$MethodChannelimpektDeepar is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelimpektDeepar>());
  });

  test('getPlatformVersion', () async {
    // impektDeepar impektDeeparPlugin = impektDeepar();
    MockimpektDeeparPlatform fakePlatform = MockimpektDeeparPlatform();
    impektDeeparPlatform.instance = fakePlatform;

    //expect(await impektDeeparPlugin.getPlatformVersion(), '42');
  });
}
