import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/update/update_controller.dart';
import 'package:fluttergran/app/update/update_platform.dart';
import 'package:fluttergran/data/update/release_version.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fake_update.dart';

void main() {
  // The launch hook listens for the app resuming, which needs a binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late FakeUpdatePlatform platform;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('update_controller');
    platform = FakeUpdatePlatform(directory);
  });

  tearDown(() => directory.delete(recursive: true));

  ProviderContainer containerWith(http.Client client) {
    final container = ProviderContainer(
      overrides: [
        updatePlatformProvider.overrideWithValue(platform),
        updateHttpClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('check', () {
    test('offers a newer release', () async {
      final container = containerWith(github());
      await container.read(updateProvider.notifier).check();

      final state = container.read(updateProvider);
      expect(state, isA<UpdateAvailable>());
      expect(state.release!.version, const ReleaseVersion(1, 1, 0));
    });

    for (final version in ['1.1.0', '1.2.0']) {
      test('is up to date on $version', () async {
        platform.version = version;
        final container = containerWith(github());
        await container.read(updateProvider.notifier).check();

        expect(container.read(updateProvider), isA<UpdateUpToDate>());
        expect(container.read(updateProvider).release, isNull);
      });
    }

    test('fails, offering nothing, when GitHub refuses', () async {
      final container = containerWith(github(status: 403));
      await container.read(updateProvider.notifier).check();

      final state = container.read(updateProvider);
      expect(state, isA<UpdateFailed>());
      expect((state as UpdateFailed).failure, UpdateFailure.check);
      expect(state.release, isNull);
    });
  });

  group('on Android', () {
    test('downloads, verifies and installs the APK for the ABI', () async {
      final container = containerWith(github());
      final updates = container.read(updateProvider.notifier);
      await updates.check();
      await updates.apply();

      final state = container.read(updateProvider);
      expect(state, isA<UpdateDownloaded>());
      expect(platform.installed, ['${directory.path}/updates/$apkName']);
      expect(await File(platform.installed.single).readAsBytes(), apkBytes);
    });

    test('never installs a download that fails its checksum', () async {
      final container = containerWith(github(checksum: '0' * 64));
      final updates = container.read(updateProvider.notifier);
      await updates.check();
      await updates.apply();

      final state = container.read(updateProvider);
      expect(state, isA<UpdateFailed>());
      expect((state as UpdateFailed).failure, UpdateFailure.download);
      expect(state.release, isNotNull);
      expect(platform.installed, isEmpty);
    });

    test('waits for permission, then installs the same file', () async {
      platform.allowed = false;
      final container = containerWith(github());
      final updates = container.read(updateProvider.notifier);
      await updates.check();
      await updates.apply();

      final waiting = container.read(updateProvider);
      expect(waiting, isA<UpdateDownloaded>());
      expect((waiting as UpdateDownloaded).needsPermission, isTrue);

      // Back from Settings without granting it: nothing happens.
      await updates.resumeInstall();
      expect(platform.installed, isEmpty);

      platform.allowed = true;
      await updates.resumeInstall();
      expect(platform.installed, [waiting.apkPath]);
      expect(
        (container.read(updateProvider) as UpdateDownloaded).needsPermission,
        isFalse,
      );
    });

    test('reports an installer that would not start', () async {
      final container = containerWith(github());
      final failing = _ThrowingInstall(directory);
      container.updateOverrides([
        updatePlatformProvider.overrideWithValue(failing),
        updateHttpClientProvider.overrideWithValue(github()),
      ]);
      final updates = container.read(updateProvider.notifier);
      await updates.check();
      await updates.apply();

      final state = container.read(updateProvider);
      expect(state, isA<UpdateFailed>());
      expect((state as UpdateFailed).failure, UpdateFailure.install);
    });
  });

  test('on Windows, opens the release page and downloads nothing', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final container = containerWith(github());
    final updates = container.read(updateProvider.notifier);
    await updates.check();
    await updates.apply();

    expect(platform.opened, [Uri.parse('$base/tag/v1.1.0')]);
    expect(platform.installed, isEmpty);
    expect(await Directory('${directory.path}/updates').exists(), isFalse);
  });

  test('on Linux, never asks GitHub', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    var asked = false;
    final container = containerWith(
      MockClient((_) async {
        asked = true;
        return http.Response('', 500);
      }),
    );
    await container.read(updateProvider.notifier).check();

    expect(asked, isFalse);
    expect(container.read(updateProvider), isA<UpdateIdle>());
  });

  group('at launch', () {
    test('checks once by itself', () async {
      final container = containerWith(github());
      container.read(updateLifecycleProvider);
      await pumpEventQueue();

      expect(container.read(updateProvider), isA<UpdateAvailable>());
    });

    test('does not check with the setting off', () async {
      final container = containerWith(github());
      await container.read(updateAutoCheckProvider.notifier).set(false);
      container.read(updateLifecycleProvider);
      await pumpEventQueue();

      expect(container.read(updateProvider), isA<UpdateIdle>());
    });

    test('does not check in a build that should not', () async {
      platform.checksAtLaunch = false;
      final container = containerWith(github());
      container.read(updateLifecycleProvider);
      await pumpEventQueue();

      expect(container.read(updateProvider), isA<UpdateIdle>());
    });
  });
}

class _ThrowingInstall extends FakeUpdatePlatform {
  _ThrowingInstall(super.directory);

  @override
  Future<InstallResult> installApk(String path) async =>
      throw PlatformException(code: 'install-failed');
}
