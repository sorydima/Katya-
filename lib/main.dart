import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katya/context/storage.dart';
import 'package:katya/global/platform.dart';
import 'package:katya/global/values.dart';
import 'package:katya/utils/theme_compatibility.dart';
import 'package:katya/views/prelock.dart';

// ignore: avoid_void_async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init platform specific code
  await initPlatformDependencies();

  // pull current context / nullable
  final context = await loadContextCurrent();

  if (SHOW_BORDERS && DEBUG_MODE) {
    debugPaintSizeEnabled = SHOW_BORDERS;
  }

  // init app
  runApp(Prelock(
    appContext: context,
    enabled: context.id.isNotEmpty && context.pinHash.isNotEmpty,
  ));
}
