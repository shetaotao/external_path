import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:external_path/external_path.dart';
import 'package:external_path/external_path_platform_interface.dart';
import 'package:external_path/external_path_method_channel.dart';

void main() {
  const MethodChannel channel = MethodChannel('external_path');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler(null);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('ExternalPath constants', () {
    test('DIRECTORY_MUSIC should be "Music"', () {
      expect(ExternalPath.DIRECTORY_MUSIC, 'Music');
    });

    test('DIRECTORY_PODCASTS should be "Podcasts"', () {
      expect(ExternalPath.DIRECTORY_PODCASTS, 'Podcasts');
    });

    test('DIRECTORY_RINGTONES should be "Ringtones"', () {
      expect(ExternalPath.DIRECTORY_RINGTONES, 'Ringtones');
    });

    test('DIRECTORY_ALARMS should be "Alarms"', () {
      expect(ExternalPath.DIRECTORY_ALARMS, 'Alarms');
    });

    test('DIRECTORY_NOTIFICATIONS should be "Notifications"', () {
      expect(ExternalPath.DIRECTORY_NOTIFICATIONS, 'Notifications');
    });

    test('DIRECTORY_PICTURES should be "Pictures"', () {
      expect(ExternalPath.DIRECTORY_PICTURES, 'Pictures');
    });

    test('DIRECTORY_MOVIES should be "Movies"', () {
      expect(ExternalPath.DIRECTORY_MOVIES, 'Movies');
    });

    test('DIRECTORY_DOWNLOAD should be "Download"', () {
      expect(ExternalPath.DIRECTORY_DOWNLOAD, 'Download');
    });

    test('DIRECTORY_DCIM should be "DCIM"', () {
      expect(ExternalPath.DIRECTORY_DCIM, 'DCIM');
    });

    test('DIRECTORY_DOCUMENTS should be "Documents"', () {
      expect(ExternalPath.DIRECTORY_DOCUMENTS, 'Documents');
    });

    test('DIRECTORY_SCREENSHOTS should be "Screenshots"', () {
      expect(ExternalPath.DIRECTORY_SCREENSHOTS, 'Screenshots');
    });

    test('DIRECTORY_AUDIOBOOKS should be "Audiobooks"', () {
      expect(ExternalPath.DIRECTORY_AUDIOBOOKS, 'Audiobooks');
    });

    test('DIRECTORY_LIBRARY should be "Library"', () {
      expect(ExternalPath.DIRECTORY_LIBRARY, 'Library');
    });

    test('DIRECTORY_CACHES should be "Caches"', () {
      expect(ExternalPath.DIRECTORY_CACHES, 'Caches');
    });

    test('DIRECTORY_APPLICATION_SUPPORT should be "ApplicationSupportDirectory"',
        () {
      expect(
          ExternalPath.DIRECTORY_APPLICATION_SUPPORT,
          'ApplicationSupportDirectory');
    });
  });

  group('MethodChannelExternalPath', () {
    late MethodChannelExternalPath methodChannelExternalPath;

    setUp(() {
      methodChannelExternalPath = MethodChannelExternalPath();
    });

    test(
        'getExternalStoragePublicDirectory should invoke method with correct type',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getExternalStoragePublicDirectory') {
          expect(methodCall.arguments, isA<Map>());
          expect(methodCall.arguments['type'], 'Download');
          return '/storage/emulated/0/Download';
        }
        return null;
      });

      final result = await methodChannelExternalPath
          .getExternalStoragePublicDirectory('Download');
      expect(result, '/storage/emulated/0/Download');
    });

    test('getExternalStoragePublicDirectory returns correct path for Pictures',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getExternalStoragePublicDirectory') {
          return '/storage/emulated/0/Pictures';
        }
        return null;
      });

      final result = await methodChannelExternalPath
          .getExternalStoragePublicDirectory('Pictures');
      expect(result, '/storage/emulated/0/Pictures');
    });

    test('getExternalStoragePublicDirectory with DCIM type', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getExternalStoragePublicDirectory') {
          expect(methodCall.arguments['type'], 'DCIM');
          return '/storage/emulated/0/DCIM';
        }
        return null;
      });

      final result = await methodChannelExternalPath
          .getExternalStoragePublicDirectory('DCIM');
      expect(result, '/storage/emulated/0/DCIM');
    });

    test('getExternalStoragePublicDirectory with Movies type', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getExternalStoragePublicDirectory') {
          return '/storage/emulated/0/Movies';
        }
        return null;
      });

      final result = await methodChannelExternalPath
          .getExternalStoragePublicDirectory('Movies');
      expect(result, '/storage/emulated/0/Movies');
    });

    test(
        'getExternalStorageDirectories should invoke method channel correctly',
        () async {
      bool methodCalled = false;
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getExternalStorageDirectories') {
          methodCalled = true;
          return [
            '/data/storage/el2/base/haps/entry/files',
            '/data/storage/el2/base/haps/entry/cache',
          ];
        }
        return null;
      });

      try {
        await methodChannelExternalPath.getExternalStorageDirectories();
      } catch (_) {}

      expect(methodCalled, isTrue);
    });
  });

  group('ExternalPathPlatform interface', () {
    test('default instance is MethodChannelExternalPath', () {
      expect(ExternalPathPlatform.instance,
          isA<MethodChannelExternalPath>());
    });

    test('getExternalStorageDirectories throws UnimplementedError on base class',
        () async {
      final platform = _FakeExternalPathPlatform();
      expect(
        () => platform.getExternalStorageDirectories(),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test(
        'getExternalStoragePublicDirectory throws UnimplementedError on base class',
        () async {
      final platform = _FakeExternalPathPlatform();
      expect(
        () => platform.getExternalStoragePublicDirectory('Download'),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('setting instance with valid token works', () {
      final original = ExternalPathPlatform.instance;
      expect(() {
        ExternalPathPlatform.instance = MethodChannelExternalPath();
      }, returnsNormally);
      ExternalPathPlatform.instance = original;
    });
  });

  group('ExternalPath static methods', () {
    test('getExternalStoragePublicDirectory delegates to platform', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getExternalStoragePublicDirectory') {
          return '/storage/emulated/0/Music';
        }
        return null;
      });

      final result =
          await ExternalPath.getExternalStoragePublicDirectory('Music');
      expect(result, '/storage/emulated/0/Music');
    });

    test(
        'getExternalStoragePublicDirectory with all directory types returns correct path',
        () async {
      final directoryTypes = [
        ExternalPath.DIRECTORY_MUSIC,
        ExternalPath.DIRECTORY_PODCASTS,
        ExternalPath.DIRECTORY_RINGTONES,
        ExternalPath.DIRECTORY_ALARMS,
        ExternalPath.DIRECTORY_NOTIFICATIONS,
        ExternalPath.DIRECTORY_PICTURES,
        ExternalPath.DIRECTORY_MOVIES,
        ExternalPath.DIRECTORY_DOWNLOAD,
        ExternalPath.DIRECTORY_DCIM,
        ExternalPath.DIRECTORY_DOCUMENTS,
        ExternalPath.DIRECTORY_SCREENSHOTS,
        ExternalPath.DIRECTORY_AUDIOBOOKS,
      ];

      for (final dirType in directoryTypes) {
        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          if (methodCall.method == 'getExternalStoragePublicDirectory') {
            return '/storage/emulated/0/$dirType';
          }
          return null;
        });

        final result =
            await ExternalPath.getExternalStoragePublicDirectory(dirType);
        expect(result, '/storage/emulated/0/$dirType');
      }
    });

    test('getExternalStorageDirectories delegates to platform', () async {
      bool methodCalled = false;
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getExternalStorageDirectories') {
          methodCalled = true;
          return ['/storage/emulated/0/Android/data/com.example/files'];
        }
        return null;
      });

      try {
        await ExternalPath.getExternalStorageDirectories();
      } catch (_) {}

      expect(methodCalled, isTrue);
    });
  });
}

class _FakeExternalPathPlatform extends ExternalPathPlatform {}
