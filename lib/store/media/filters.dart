import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:katya/global/print.dart';
import 'package:katya/store/media/converters.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<File?> scrubMedia({
  required File localFile,
  String mediaNameFull = 'media-default',
}) async {
  try {
    // Extension handling
    final mimeTypeOption = lookupMimeType(localFile.path);
    final mimeType = convertMimeTypes(localFile, mimeTypeOption);

    // Image file info
    final String fileType = mimeType;
    final String fileExtension = fileType.split('/')[1];
    final String mediaName = mediaNameFull.split('.')[0];
    final String fileName = '$mediaName-scrubbed.$fileExtension';
    final fileImage = await decodeImageFromList(
      localFile.readAsBytesSync(),
    );

    var format;

    switch (fileExtension.toLowerCase()) {
      case 'png':
        format = CompressFormat.png;
      case 'jpeg':
        format = CompressFormat.jpeg;
      case 'heic':
        format = CompressFormat.heic;
      case 'webp':
        format = CompressFormat.webp;
      default:
        // Can't remove exif info for this media type
        return localFile;
    }

    final mediaScrubbed = await FlutterImageCompress.compressWithFile(
      localFile.absolute.path,
      quality: 100,
      minWidth: fileImage.width,
      minHeight: fileImage.height,
      format: format,
      keepExif: false,
      numberOfRetries: 1,
      autoCorrectionAngle: false,
    );

    if (mediaScrubbed == null) {
      throw 'Failed to remove EXIF data from media';
    }

    final directory = await getTemporaryDirectory();
    final tempFile = File(path.join(directory.path, fileName));

    return await tempFile.writeAsBytes(mediaScrubbed, flush: true);
  } catch (error) {
    log.error(error.toString());
    return null;
  }
}
