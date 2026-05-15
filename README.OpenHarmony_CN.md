# external_path

<p align="center">external_path</p>

本项目基于 [external_path](https://github.com/aakashkondhalkar/external_path.git) 开发。

## 简介

external_path 是一个 Flutter 插件，用于获取 OpenHarmony 设备的应用沙箱目录路径。

> **平台差异说明**：由于 OpenHarmony 采用应用沙箱机制，与原库的 Android/iOS 实现存在差异。本插件返回的是应用沙箱内的目录路径，而非传统意义上的外部存储路径。

## 下载安装

在项目的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  external_path:
    git:
      url: https://gitcode.com/OpenHarmony-Flutter/fluttertpc_external_path.git
      ref: 2.2.0-ohos-1.0.0
```

然后执行以下命令安装依赖：

```bash
flutter pub get
```

### TAG 版本对应表

| Flutter 框架版本 | TAG 名称 | 分支名 |
|---|---|---|
| 3.22 | 2.2.0-ohos-1.0.0| master |
| 3.27 | 2.2.0-ohos-1.0.0 | master |
| 3.35 | 2.2.0-ohos-1.0.0 | master |

## 约束与限制

### 兼容性

1. Flutter: 3.22.1-ohos-1.1.0; SDK: 5.0.0(12); IDE: DevEco Studio: 6.1.0.830; ROM: 6.1.0.117 SP6;
2. Flutter: 3.27.5-ohos-1.0.4; SDK: 5.0.0(12); IDE: DevEco Studio: 6.1.0.830; ROM: 6.1.0.117 SP6;
3. Flutter: 3.35.8-ohos-0.0.2; SDK: 5.0.0(12); IDE: DevEco Studio: 6.1.0.830; ROM: 6.1.0.117 SP6;

### 权限要求

本插件不需要额外权限，所有返回的路径均在应用沙箱内。

## 使用示例

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

  // 初始化：获取存储路径
  Future<void> _initPaths() async {
    // 获取应用沙箱目录路径（filesDir、cacheDir）
    List<String>? paths = await ExternalPath.getExternalStorageDirectories();
    
    // 获取文档目录路径（沙箱内 Documents 子目录）
    String docPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOCUMENTS,
    );
    
    // 获取下载目录路径（沙箱内 Download 子目录）
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
          title: const Text('External Path 示例'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '沙箱目录列表:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._storagePaths.map((path) => Text(path)).toList(),
              const SizedBox(height: 16),
              const Text(
                '文档目录路径:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_documentsPath),
              const SizedBox(height: 16),
              const Text(
                '下载目录路径:',
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

## 使用说明

### 获取应用沙箱目录路径

使用 `ExternalPath.getExternalStorageDirectories()` 获取应用沙箱内的目录路径列表。

```dart
List<String>? paths = await ExternalPath.getExternalStorageDirectories();
// 输出示例: [/data/app/el2/100/base/com.example/files, /data/app/el2/100/base/com.example/cache]
```

**返回路径说明：**
- `filesDir`：应用文件目录（对应沙箱内 `files` 目录）
- `cacheDir`：应用缓存目录（对应沙箱内 `cache` 目录）

### 获取公共目录路径

使用 `ExternalPath.getExternalStoragePublicDirectory(type)` 获取指定类型的目录路径。

```dart
String documentsPath = await ExternalPath.getExternalStoragePublicDirectory(
  ExternalPath.DIRECTORY_DOCUMENTS,
);
// 输出示例（PC/2in1）: /Users/username/Documents
// 输出示例（手机/平板）: /data/app/el2/100/base/com.example/files/Documents
```

> **重要提示**：
> - 媒体类目录（Music、Pictures、Movies 等）在 OpenHarmony 上无法直接访问
> - PC/2in1 设备支持访问公共 Download 和 Documents 目录，手机/平板设备将回退到应用沙箱内的子目录

## 接口说明

#### 方法

| 方法名 | 返回值类型 | 参数 | 说明 | OpenHarmony 行为 |
|--------|-----------|------|------|-----------------|
| `getExternalStorageDirectories()` | `Future<List<String>?>` | 无 | 获取存储目录路径列表 | 返回沙箱 filesDir 和 cacheDir |
| `getExternalStoragePublicDirectory(type)` | `Future<String>` | `type`: String - 目录类型常量 | 获取指定类型的公共目录路径 | 根据类型返回沙箱路径或空字符串 |

#### 常量

| 常量名 | 类型 | 说明 | OpenHarmony 支持 |
|--------|------|------|-----------------|
| `DIRECTORY_DOWNLOAD` | `String` | 下载目录 | ✔️ 支持 |
| `DIRECTORY_DOCUMENTS` | `String` | 文档目录 | ✔️ 支持 |
| `DIRECTORY_LIBRARY` | `String` | iOS 库目录 | ⚠️ 映射到 preferencesDir |
| `DIRECTORY_CACHES` | `String` | iOS 缓存目录 | ⚠️ 映射到 cacheDir |
| `DIRECTORY_APPLICATION_SUPPORT` | `String` | iOS 应用支持目录 | ⚠️ 映射到 databaseDir |
| `DIRECTORY_MUSIC` | `String` | 音乐目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_PICTURES` | `String` | 图片目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_DCIM` | `String` | 相机照片目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_MOVIES` | `String` | 视频目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_PODCASTS` | `String` | 播客目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_RINGTONES` | `String` | 铃声目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_ALARMS` | `String` | 闹钟目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_NOTIFICATIONS` | `String` | 通知目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_SCREENSHOTS` | `String` | 截图目录 | ❌️ 不支持（返回空字符串） |
| `DIRECTORY_AUDIOBOOKS` | `String` | 有声读物目录 | ❌️ 不支持（返回空字符串） |

### 平台差异说明

> **OpenHarmony 与 Android/iOS 的主要差异：**
> 1. `getExternalStorageDirectories()` 返回应用沙箱目录（filesDir、cacheDir），而非外部存储路径
> 2. 媒体类目录（Music、Pictures、Movies 等）返回空字符串
> 3. iOS 专属目录（Library、Caches、ApplicationSupport）映射到对应沙箱目录

## 目录结构

```
external_path/
├── lib/                          # Dart 代码目录
│   ├── external_path.dart        # 主入口文件
│   ├── external_path_method_channel.dart    # MethodChannel 实现
│   └── external_path_platform_interface.dart # 平台接口定义
├── ohos/                         # OpenHarmony 平台代码
│   └── src/main/ets/com/pinciat/external_path/
│       └── ExternalPathPlugin.ets   # OpenHarmony 插件实现
├── example/                      # 示例应用
│   ├── lib/
│   │   └── main.dart            # 示例代码
│   └── ohos/                    # OpenHarmony 示例
├── pubspec.yaml                 # 包配置文件
├── README.md                    # 原库文档
├── README.OpenHarmony_CN.md     # 中文文档
└── README.OpenHarmony.md        # 英文文档
```

## 贡献代码

欢迎提交 Issue 和 Pull Request 来帮助改进本项目。

GitCode 仓库地址：https://gitcode.com/openharmony-sig/fluttertpc_external_path

## 开源协议

本项目基于 BSD-3-Clause 协议开源，详见 [LICENSE](LICENSE) 文件。

原库地址：https://github.com/aakashkondhalkar/external_path.git
