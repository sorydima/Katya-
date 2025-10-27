// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:katya/global/values.dart';

typedef PrintJson = void Function(Map? jsonMap);
typedef PrintDebug = void Function(String message, {String title});
typedef PrintError = void Function(String message, {String? title});

void _printThreaded(String content, {String? title}) {
  if (DEBUG_MODE) {
    final output = title != null ? '[$title] $content' : content;
    print('[bg   ] $output');
  }
}

void _printInfo(String content, {String? title}) {
  if (DEBUG_MODE) {
    final output = title != null ? '[$title] $content' : content;
    print('[info ] $output');
  }
}

void _printWarning(String content, {String? title}) {
  if (DEBUG_MODE) {
    final output = title != null ? '[$title] $content' : content;
    print('[warn ] $output');
  }
}

void _printError(String content, {String? title}) {
  if (DEBUG_MODE) {
    final output = title != null ? '[$title] $content' : content;
    print('[ERROR] $output');
  }
}

void _printRelease(String content, {String? title}) {
  final output = title != null ? '[$title] $content' : content;
  print('[prod ] $output');
}

void _printDebug(String content, {String? title}) {
  if (DEBUG_MODE) {
    final output = title != null ? '[$title] $content' : content;
    print('[DEBUG] $output');
  }
}

void _printJson(Map? jsonMap) {
  if (DEBUG_MODE) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyEvent = encoder.convert(jsonMap);
    debugPrint(prettyEvent, wrapWidth: 2048);
  }
}

// NOTE: start using this for better tab completion
// ignore: camel_case_types
class log {
  static void info(String content, {String? title}) => _printInfo(content, title: title);
  static void warn(String content, {String? title}) => _printWarning(content, title: title);
  static void error(String content, {String? title}) => _printError(content, title: title);
  static void debug(String content, {String? title}) => _printDebug(content, title: title);
  static void threaded(String content, {String? title}) => _printThreaded(content, title: title);
  static void release(String content, {String? title}) => _printRelease(content, title: title);
  static void json(Map? json) => _printJson(json);
  static void jsonDebug(Map? json) => _printJson(json);
}
