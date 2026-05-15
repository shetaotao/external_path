/*
 * Copyright (C) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { Environment } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const LOG_DOMAIN: number = 0xFF00;
const LOG_TAG: string = 'ExternalPathPlugin';

/** ExternalPathPlugin **/
export default class ExternalPathPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private context: common.Context | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "ExternalPathPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext();
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "external_path");
    this.channel.setMethodCallHandler(this);
    hilog.debug(LOG_DOMAIN, LOG_TAG, 'onAttachedToEngine called');
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    hilog.debug(LOG_DOMAIN, LOG_TAG, 'onDetachedFromEngine called');
    this.context = null;
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
    this.channel = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    hilog.debug(LOG_DOMAIN, LOG_TAG, 'onMethodCall: method=%{public}s', call.method);
    
    if (call.method == "getExternalStorageDirectories") {
      this.handleGetExternalStorageDirectories(result);
    } else if (call.method == "getExternalStoragePublicDirectory") {
      this.handleGetExternalStoragePublicDirectory(call, result);
    } else {
      hilog.warn(LOG_DOMAIN, LOG_TAG, 'Unknown method: %{public}s', call.method);
      result.notImplemented();
    }
  }

  /**
   * 获取应用沙箱存储目录列表
   * HarmonyOS 采用沙箱模型，返回应用沙箱内的路径（filesDir、cacheDir）
   */
  private handleGetExternalStorageDirectories(result: MethodResult): void {
    hilog.debug(LOG_DOMAIN, LOG_TAG, 'handleGetExternalStorageDirectories called');
    
    if (this.context === null) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'Context is null');
      result.error('ERROR', 'Context is not available', null);
      return;
    }

    const paths: string[] = [];
    
    // 添加 filesDir（应用文件目录）
    const filesDir = this.context.filesDir;
    if (filesDir !== null && filesDir !== undefined && filesDir.length > 0) {
      paths.push(filesDir);
      hilog.debug(LOG_DOMAIN, LOG_TAG, 'filesDir: %{public}s', filesDir);
    }
    
    // 添加 cacheDir（应用缓存目录）
    const cacheDir = this.context.cacheDir;
    if (cacheDir !== null && cacheDir !== undefined && cacheDir.length > 0) {
      paths.push(cacheDir);
      hilog.debug(LOG_DOMAIN, LOG_TAG, 'cacheDir: %{public}s', cacheDir);
    }

    hilog.debug(LOG_DOMAIN, LOG_TAG, 'Returning %{public}d paths', paths.length);
    result.success(paths);
  }

  /**
   * 获取公共目录路径
   * 根据目录类型返回对应的沙箱内路径或公共目录路径
   */
  private handleGetExternalStoragePublicDirectory(call: MethodCall, result: MethodResult): void {
    hilog.debug(LOG_DOMAIN, LOG_TAG, 'handleGetExternalStoragePublicDirectory called');
    
    if (this.context === null) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'Context is null');
      result.error('ERROR', 'Context is not available', null);
      return;
    }

    // 提取参数
    const args = call.args as Map<string, Object>;
    if (args === null || args === undefined) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'Args is null');
      result.error('ERROR', 'No arguments provided', null);
      return;
    }

    const typeValue = args.get('type');
    if (typeValue === null || typeValue === undefined) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'type parameter is missing');
      result.error('ERROR', 'type parameter is required', null);
      return;
    }

    const type = typeValue as string;
    hilog.debug(LOG_DOMAIN, LOG_TAG, 'Requested directory type: %{public}s', type);

    const path = this.getPublicDirectoryPath(type);
    hilog.debug(LOG_DOMAIN, LOG_TAG, 'Returning path: %{public}s', path);
    result.success(path);
  }

  /**
   * 根据目录类型获取对应的路径
   */
  private getPublicDirectoryPath(type: string): string {
    if (this.context === null) {
      return '';
    }

    switch (type) {
      case 'Download':
        // 尝试使用 Environment API（仅 PC/2in1 设备支持）
        // 失败时回退到沙箱内 Download 子目录
        return this.getDownloadDir();
      
      case 'Documents':
        // 尝试使用 Environment API（仅 PC/2in1 设备支持）
        // 失败时回退到沙箱内 Documents 子目录
        return this.getDocumentsDir();
      
      case 'Library':
        // iOS 专属，映射到 preferencesDir
        const preferencesDir = this.context.preferencesDir;
        if (preferencesDir !== null && preferencesDir !== undefined) {
          return preferencesDir;
        }
        return '';
      
      case 'Caches':
        // iOS 专属，映射到 cacheDir
        const cacheDir = this.context.cacheDir;
        if (cacheDir !== null && cacheDir !== undefined) {
          return cacheDir;
        }
        return '';
      
      case 'ApplicationSupportDirectory':
        // iOS 专属，映射到 databaseDir
        const databaseDir = this.context.databaseDir;
        if (databaseDir !== null && databaseDir !== undefined) {
          return databaseDir;
        }
        return '';
      
      case 'Music':
      case 'Pictures':
      case 'DCIM':
      case 'Movies':
      case 'Podcasts':
      case 'Ringtones':
      case 'Alarms':
      case 'Notifications':
      case 'Screenshots':
      case 'Audiobooks':
        // 媒体目录在 HarmonyOS 上无法直接访问，需要使用 Picker
        // 返回空字符串，与 iOS 不支持目录时的行为一致
        hilog.warn(LOG_DOMAIN, LOG_TAG, 
          'Directory type %{public}s is not supported on HarmonyOS. Use Picker instead.', type);
        return '';
      
      default:
        hilog.warn(LOG_DOMAIN, LOG_TAG, 'Unknown directory type: %{public}s', type);
        return '';
    }
  }

  /**
   * 获取下载目录
   * 优先尝试 Environment.getUserDownloadDir()（仅 PC/2in1 设备支持）
   * 失败时回退到沙箱内 Download 子目录
   */
  private getDownloadDir(): string {
    // 先尝试 Environment API
    try {
      const downloadDir = Environment.getUserDownloadDir();
      if (downloadDir !== null && downloadDir !== undefined && downloadDir.length > 0) {
        hilog.debug(LOG_DOMAIN, LOG_TAG, 'Using Environment.getUserDownloadDir(): %{public}s', downloadDir);
        return downloadDir;
      }
    } catch (error) {
      // Environment API 仅支持 PC/2in1 设备，手机/平板会抛出错误
      hilog.debug(LOG_DOMAIN, LOG_TAG, 
        'Environment.getUserDownloadDir() not available, falling back to sandbox directory');
    }

    // 回退到沙箱内 Download 子目录
    if (this.context === null) {
      return '';
    }
    const sandboxDownloadPath = `${this.context.filesDir}/Download`;
    return this.ensureDir(sandboxDownloadPath);
  }

  /**
   * 获取文档目录
   * 优先尝试 Environment.getUserDocumentDir()（仅 PC/2in1 设备支持）
   * 失败时回退到沙箱内 Documents 子目录
   */
  private getDocumentsDir(): string {
    // 先尝试 Environment API
    try {
      const documentsDir = Environment.getUserDocumentDir();
      if (documentsDir !== null && documentsDir !== undefined && documentsDir.length > 0) {
        hilog.debug(LOG_DOMAIN, LOG_TAG, 'Using Environment.getUserDocumentDir(): %{public}s', documentsDir);
        return documentsDir;
      }
    } catch (error) {
      // Environment API 仅支持 PC/2in1 设备，手机/平板会抛出错误
      hilog.debug(LOG_DOMAIN, LOG_TAG, 
        'Environment.getUserDocumentDir() not available, falling back to sandbox directory');
    }

    // 回退到沙箱内 Documents 子目录
    if (this.context === null) {
      return '';
    }
    const sandboxDocumentsPath = `${this.context.filesDir}/Documents`;
    return this.ensureDir(sandboxDocumentsPath);
  }

  /**
   * 确保目录存在，不存在则创建
   */
  private ensureDir(path: string): string {
    try {
      // 检查目录是否存在
      const exists = fileIo.accessSync(path);
      if (!exists) {
        // 目录不存在，创建它
        fileIo.mkdirSync(path);
        hilog.debug(LOG_DOMAIN, LOG_TAG, 'Created directory: %{public}s', path);
      }
      return path;
    } catch (error) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'Failed to ensure directory %{public}s: %{public}s', 
        path, (error as Error).message);
      return '';
    }
  }
}
