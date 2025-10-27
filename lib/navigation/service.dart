import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigator!.pushReplacementNamed<T, TO>(routeName, arguments: arguments, result: result);
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    RoutePredicate? predicate,
  }) {
    return navigator!.pushNamedAndRemoveUntil<T>(routeName, predicate ?? (route) => false, arguments: arguments);
  }

  static void pop<T extends Object?>([T? result]) {
    navigator!.pop<T>(result);
  }

  static void popUntil(RoutePredicate predicate) {
    navigator!.popUntil(predicate);
  }
}
