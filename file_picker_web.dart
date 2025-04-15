import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/file_picker_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FilePickerWeb extends FilePickerWebPlugin {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
  }) async {
    try {
      final input = html.FileUploadInputElement()
        ..accept = _getFileType(type, allowedExtensions)
        ..multiple = allowMultiple;
      
      input.click();

      await input.onChange.first;
      
      if (input.files!.isEmpty) return null;
      
      final files = input.files!
          .map((file) => PlatformFile(
                name: file.name,
                size: file.size,
                bytes: withData ? await _readFile(file) : null,
                path: file.name,
              ))
          .toList();

      return FilePickerResult(files);
    } catch (e) {
      debugPrint('File picker error: $e');
      return null;
    }
  }

  String? _getFileType(FileType type, List<String>? allowedExtensions) {
    switch (type) {
      case FileType.any:
        return allowedExtensions?.join(',');
      case FileType.image:
        return 'image/*';
      case FileType.video:
        return 'video/*';
      case FileType.audio:
        return 'audio/*';
      case FileType.media:
        return 'video/*,image/*,audio/*';
      case FileType.custom:
        return allowedExtensions?.join(',');
      default:
        return null;
    }
  }

  Future<Uint8List> _readFile(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return reader.result as Uint8List;
  }
}