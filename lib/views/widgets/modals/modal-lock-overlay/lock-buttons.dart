import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

/// [OutlinedButton] based button.
class LockButton extends StatelessWidget {
  const LockButton({
    Key? key,
    this.disabled = false,
    this.config = const Object(), // Simplified for compatibility
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  final bool disabled;
  final Widget child;
  final Object config; // Using Object for compatibility
  final void Function() onPressed;

  double computeHeight(Size boxSize) {
    // if (config.autoSize) { // Simplified for compatibility
    //   return _computeAutoSize(boxSize);
    // }

    return boxSize.height;
  }

  double computeWidth(Size boxSize) {
    // if (config.autoSize) { // Simplified for compatibility
    //   return _computeAutoSize(boxSize);
    // }

    return boxSize.width;
  }

  Size defaultSize(BuildContext context) {
    return Size(
      // config.height ?? // Simplified for compatibility
      MediaQuery.of(context).size.height * 0.6 * 0.16,

      /// Subtract padding(horizontal: 50) from screen_lock.dart to calculate
      // config.width ?? // Simplified for compatibility
      (MediaQuery.of(context).size.width - 100) * 0.22,
    );
  }

  EdgeInsetsGeometry defaultMargin() {
    return const EdgeInsets.all(10);
  }

  double _computeAutoSize(Size size) {
    return size.width < size.height ? size.width : size.height;
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = defaultSize(context);

    return Container(
      width: computeWidth(boxSize),
      height: computeHeight(boxSize),
      margin: const EdgeInsets.all(10),
      color: Colors.transparent,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom().copyWith(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
            ),
        child: child,
      ),
    );
  }
}
