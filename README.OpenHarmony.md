# external_path

<p align="center">external_path</p>

This project is developed based on [external_path](https://github.com/aakashkondhalkar/external_path.git).

## Introduction

external_path is a Flutter plugin for getting application sandbox directory paths on OpenHarmony devices.

> **Platform Differences**: Due to OpenHarmony's application sandbox mechanism, there are differences from the original library's Android/iOS implementation. This plugin returns paths within the application sandbox, rather than traditional external storage paths.

## Download and Installation

Add the dependency in your project's `pubspec.yaml` file:

```yaml
dependencies:
  external_path:
    git:
      url: https://gitcode.com/OpenHarmony-Flutter/fluttertpc_external_path.git
      ref: 2.2.0-ohos-1.0.0
```

Then run the following command to install the dependency:

```bash
flutter pub get
```

### TAG Version Mapping Table

| Flutter Framework Version | TAG Name | Branch |
|---|---|---|
| 3.22 | 2.2.0-ohos-1.0.0 | master |
| 3.27 | 2.2.0-ohos-1.0.0 | master |
| 3.35 | 2.2.0-ohos-1.0.0 | master |

## Constraints and Limitations

### Compatibility

1. Flutter: 3.22.1-ohos-1.1.0; SDK: 5.0.0(12); IDE: DevEco Studio: 6.1.0.830; ROM: 6.1.0.117 SP6;
2. Flutter: 3.27.5-ohos-1.0.4; SDK: 5.0.0(12); IDE: DevEco Studio: 6.1.0.830; ROM: 6.1.0.117 SP6;
3. Flutter: 3.35.8-ohos-0.0.2; SDK: 5.0.0(12); IDE: DevEco Studio: 6.1.0.830; ROM: 6.1.0.117 SP6;

### Permission Requirements

This plugin does not require additional permissions. All returned paths are within the application sandbox.

## Usage Example

```dart
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> _storagePaths = [];
  String _documentsPath = '';
  String _downloadPath = '';

  @override
  void initState() {
    super.initState();
    _initPaths();
  }

  // Initialize: Get storage paths
  Future<void> _initPaths() async {
    // Get application sandbox directory paths (filesDir, cacheDir)
    List<String>? paths = await ExternalPath.getExternalStorageDirectories();
    
    // Get documents directory path (Documents subdirectory in sandbox)
    String docPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOCUMENTS,
    );
    
    // Get download directory path (Download subdirectory in sandbox)
    String dlPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOAD,
    );

    setState(() {
      _storagePaths = paths ?? [];
      _documentsPath = docPath;
      _downloadPath = dlPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('External Path Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sandbox Directories:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._storagePaths.map((path) => Text(path)).toList(),
              const SizedBox(height: 16),
              const Text(
                'Documents Path:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_documentsPath),
              const SizedBox(height: 16),
              const Text(
                'Download Path:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_downloadPath),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Usage Instructions

### Get Application Sandbox Directory Paths

Use `ExternalPath.getExternalStorageDirectories()` to get a list of directory paths within the application sandbox.

```dart
List<String>? paths = await ExternalPath.getExternalStorageDirectories();
// Example output: [/data/app/el2/100/base/com.example/files, /data/app/el2/100/base/com.example/cache]
```

**Returned Paths Description:**
- `filesDir`: Application files directory (corresponds to `files` directory in sandbox)
- `cacheDir`: Application cache directory (corresponds to `cache` directory in sandbox)

### Get Public Directory Path

Use `ExternalPath.getExternalStoragePublicDirectory(type)` to get the directory path of the specified type.

```dart
String documentsPath = await ExternalPath.getExternalStoragePublicDirectory(
  ExternalPath.DIRECTORY_DOCUMENTS,
);
// Example output (PC/2in1): /Users/username/Documents
// Example output (Phone/Tablet): /data/app/el2/100/base/com.example/files/Documents
```

> **Important Notes**:
> - Media directories (Music, Pictures, Movies, etc.) cannot be directly accessed on OpenHarmony.
> - PC/2in1 devices support accessing public Download and Documents directories. Phone/tablet devices will fall back to subdirectories within the application sandbox.

## API Reference

#### Methods

| Method Name | Return Type | Parameters | Description | OpenHarmony Behavior |
|--------|-----------|------|------|-----------------|
| `getExternalStorageDirectories()` | `Future<List<String>?>` | None | Get a list of storage directory paths | Returns sandbox filesDir and cacheDir |
| `getExternalStoragePublicDirectory(type)` | `Future<String>` | `type`: String - Directory type constant | Get the public directory path of the specified type | Returns sandbox path or empty string based on type |

#### Constants

| Constant Name | Type | Description | OpenHarmony Support |
|--------|------|------|-----------------|
| `DIRECTORY_DOWNLOAD` | `String` | Downloads directory | ✔️ Supported |
| `DIRECTORY_DOCUMENTS` | `String` | Documents directory | ✔️ Supported |
| `DIRECTORY_LIBRARY` | `String` | iOS Library directory | ⚠️ Mapped to preferencesDir |
| `DIRECTORY_CACHES` | `String` | iOS Caches directory | ⚠️ Mapped to cacheDir |
| `DIRECTORY_APPLICATION_SUPPORT` | `String` | iOS Application Support directory | ⚠️ Mapped to databaseDir |
| `DIRECTORY_MUSIC` | `String` | Music directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_PICTURES` | `String` | Pictures directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_DCIM` | `String` | Camera photos directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_MOVIES` | `String` | Movies directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_PODCASTS` | `String` | Podcasts directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_RINGTONES` | `String` | Ringtones directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_ALARMS` | `String` | Alarms directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_NOTIFICATIONS` | `String` | Notifications directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_SCREENSHOTS` | `String` | Screenshots directory | ❌️ Not supported (Returns empty string) |
| `DIRECTORY_AUDIOBOOKS` | `String` | Audiobooks directory | ❌️ Not supported (Returns empty string) |

### Platform Differences

> **Key Differences Between OpenHarmony and Android/iOS:**
> 1. `getExternalStorageDirectories()` returns application sandbox directories (filesDir, cacheDir), not external storage paths
> 2. Media directories (Music, Pictures, Movies, etc.) return empty strings
> 3. iOS-specific directories (Library, Caches, ApplicationSupport) are mapped to corresponding sandbox directories


## Directory Structure

```
external_path/
├── lib/                          # Dart code directory
│   ├── external_path.dart        # Main entry file
│   ├── external_path_method_channel.dart    # MethodChannel implementation
│   └── external_path_platform_interface.dart # Platform interface definition
├── ohos/                         # OpenHarmony platform code
│   └── src/main/ets/com/pinciat/external_path/
│       └── ExternalPathPlugin.ets   # OpenHarmony plugin implementation
├── example/                      # Example application
│   ├── lib/
│   │   └── main.dart            # Example code
│   └── ohos/                    # OpenHarmony example
├── pubspec.yaml                 # Package configuration file
├── README.md                    # Original library documentation
├── README.OpenHarmony_CN.md     # Chinese documentation
└── README.OpenHarmony.md        # English documentation
```

## Contributing

Issues and Pull Requests are welcome to help improve this project.

GitCode Repository: https://gitcode.com/openharmony-sig/fluttertpc_external_path

## License

This project is open-sourced under the BSD-3-Clause License. See the [LICENSE](LICENSE) file for details.

Original Repository: https://github.com/aakashkondhalkar/external_path.git
