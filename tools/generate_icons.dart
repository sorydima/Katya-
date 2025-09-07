import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

/// Tool for generating app icons from source images
/// Usage: dart tools/generate_icons.dart <source_image> [output_dir]
void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart tools/generate_icons.dart <source_image> [output_dir]');
    print('Example: dart tools/generate_icons.dart assets/icon_source.png assets/icons/');
    exit(1);
  }

  final sourcePath = args[0];
  final outputDir = args.length > 1 ? args[1] : 'assets/icons/generated/';

  try {
    generateIcons(sourcePath, outputDir);
    print('✅ Icons generated successfully!');
  } catch (e) {
    print('❌ Error generating icons: $e');
    exit(1);
  }
}

void generateIcons(String sourcePath, String outputDir) {
  // Check if source file exists
  final sourceFile = File(sourcePath);
  if (!sourceFile.existsSync()) {
    throw Exception('Source file does not exist: $sourcePath');
  }

  // Create output directory
  final outputDirectory = Directory(outputDir);
  if (!outputDirectory.existsSync()) {
    outputDirectory.createSync(recursive: true);
  }

  // Load and decode image
  final bytes = sourceFile.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    throw Exception('Failed to decode image');
  }

  print('📷 Processing image: ${path.basename(sourcePath)}');

  // Icon sizes for different platforms
  final iconSizes = {
    // Android
    'android/mipmap-mdpi/ic_launcher.png': 48,
    'android/mipmap-hdpi/ic_launcher.png': 72,
    'android/mipmap-xhdpi/ic_launcher.png': 96,
    'android/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/mipmap-xxxhdpi/ic_launcher.png': 192,

    // iOS
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png': 20,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png': 40,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png': 60,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png': 29,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png': 58,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png': 87,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png': 40,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png': 80,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png': 120,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png': 120,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png': 180,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png': 76,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png': 152,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png': 167,

    // Web
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/favicon.png': 32,

    // Windows
    'windows/runner/resources/app_icon.ico': 256,

    // macOS
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16x16.png': 16,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32x32.png': 32,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64x64.png': 64,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128x128.png': 128,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256x256.png': 256,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512x512.png': 512,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024x1024.png': 1024,

    // Linux
    'linux/data/flutter_assets/assets/icons/icon_64x64.png': 64,
    'linux/data/flutter_assets/assets/icons/icon_128x128.png': 128,
    'linux/data/flutter_assets/assets/icons/icon_256x256.png': 256,
  };

  // Generate icons for each size
  for (final entry in iconSizes.entries) {
    final outputPath = path.join(outputDir, entry.key);
    final size = entry.value;

    print('🎨 Generating: ${entry.key} (${size}x${size})');

    // Create directory if it doesn't exist
    final dir = Directory(path.dirname(outputPath));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // Resize image
    final resized = img.copyResize(
      image,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );

    // Save image
    final outputBytes = entry.key.endsWith('.ico')
        ? img.encodeIco(resized)
        : img.encodePng(resized);

    File(outputPath).writeAsBytesSync(outputBytes);
  }

  print('✅ Generated ${iconSizes.length} icon variants');
  print('📁 Output directory: $outputDir');
}
